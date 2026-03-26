package controllers

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// AdminApproveProduct handles api/admin/product/approve
func AdminApproveProduct(c *gin.Context) {
	productIDStr := c.PostForm("product id")
	approvedStr := c.PostForm("approved")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)
	approved, _ := strconv.ParseBool(approvedStr)

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": productID}, bson.M{"$set": bson.M{"approved": approved}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	msg := "successfully approved"
	if !approved {
		msg = "desapproved"
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": msg})
}

// AdminHideProduct handles api/admin/product/hide
func AdminHideProduct(c *gin.Context) {
	productIDStr := c.PostForm("product id")
	hideStr := c.PostForm("hide")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)
	hide, _ := strconv.ParseBool(hideStr)

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": productID}, bson.M{"$set": bson.M{"hidden": hide}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	msg := "successfully hidden"
	if !hide {
		msg = "removed from hidden"
	}
	// Note: Replaced textual typo from the spec where modifying "hide" was returning "desapproved" successfully!
	c.JSON(http.StatusOK, gin.H{"success": true, "message": msg})
}

// AdminGetAllProduct handles /api/admin/product/all
func AdminGetAllProduct(c *gin.Context) {
	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{}, options.Find().SetLimit(100))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, p := range results {
		mapped = append(mapped, gin.H{
			"Product id":        p["_id"],
			"name":              p["name"],
			"short description": p["short_description"],
			"price per unit":    p["price_per_unit"],
			"product category":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand_name"],
			"hidden":            p["hidden"],
			"approved":          p["approved"],
			"toupdate":          p["toupdate"],
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// AdminAddCategory handles /api/admin/categories/add
func AdminAddCategory(c *gin.Context) {
	name := c.PostForm("name")
	deliveryType := c.PostForm("quick/normal")
	required := c.PostForm("required")
	others := c.PostForm("others")

	coll := utils.GetCollection("categories")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cat := bson.M{
		"name":            name,
		"delivery_type":   deliveryType,
		"required_fields": required,
		"other_fields":    others,
		"hidden":          false,
	}

	_, err := coll.InsertOne(ctx, cat)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// AdminEditCategory handles /api/admin/categories/edit
func AdminEditCategory(c *gin.Context) {
	catIDStr := c.PostForm("category id")
	name := c.PostForm("name")
	deliveryType := c.PostForm("quick/normal")
	required := c.PostForm("required")
	others := c.PostForm("others")

	catID, _ := primitive.ObjectIDFromHex(catIDStr)

	coll := utils.GetCollection("categories")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	update := bson.M{
		"name":            name,
		"delivery_type":   deliveryType,
		"required_fields": required,
		"other_fields":    others,
	}

	_, err := coll.UpdateOne(ctx, bson.M{"_id": catID}, bson.M{"$set": update})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully edited"})
}

// AdminHideCategory handles /api/admin/categories/hide
func AdminHideCategory(c *gin.Context) {
	catIDStr := c.PostForm("category id")
	hiddenStr := c.PostForm("hidden")
	catID, _ := primitive.ObjectIDFromHex(catIDStr)
	hidden, _ := strconv.ParseBool(hiddenStr)

	coll := utils.GetCollection("categories")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": catID}, bson.M{"$set": bson.M{"hidden": hidden}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully hidden"})
}

// GetAllCategories handles /api/category/all
func GetAllCategories(c *gin.Context) {
	coll := utils.GetCollection("categories")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{"hidden": bson.M{"$ne": true}}, options.Find().SetLimit(100))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for i, cat := range results {
		name, _ := cat["name"].(string)
		mapped = append(mapped, gin.H{
			"id":   i + 1,
			"name": name,
			"_id":  cat["_id"], // Behind the scenes true ID mapped
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "category fetched successfully",
		"data":    mapped,
	})
}

// AdminProductGetByID handles /api/admin/product/id
func AdminProductGetByID(c *gin.Context) {
	productIDStr := c.Query("product id")
	if productIDStr == "" {
		productIDStr = c.PostForm("product id")
	}
	productID, _ := primitive.ObjectIDFromHex(productIDStr)

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var p bson.M
	err := coll.FindOne(ctx, bson.M{"_id": productID}).Decode(&p)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"id":                 p["_id"],
			"Name":               p["name"],
			"brand":              p["brand_name"],
			"description":        p["description"],
			"short descriptions": p["short_description"],
			"price per unit":     p["price_per_unit"],
			"unit ( kg, .. )":    p["unit"],
			"discount":           p["discount"],
			"product catagory":   p["product_category"],
			"delivary categpory": p["delivery_category"],
			"stock : num":        p["stock"],
			"Photos":             p["photos"],
			"vender id":          p["vendor_id"],
			"vender name":        "vender name", // Stub placeholder
			"rating":             p["rating"],
		},
	})
}
