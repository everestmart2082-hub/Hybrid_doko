package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// GetAllProducts handles /api/product/all
func GetAllProducts(c *gin.Context) {
	cat := c.Query("product category")
	if cat == "" {
		cat = c.PostForm("product category")
	}
	vendorIDStr := c.Query("vender id")

	filter := bson.M{"hidden": bson.M{"$ne": true}, "approved": true}
	if cat != "" {
		filter["product_category"] = cat
	}
	if vendorIDStr != "" {
		if vid, err := primitive.ObjectIDFromHex(vendorIDStr); err == nil {
			filter["vendor_id"] = vid
		}
	}

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, filter, options.Find().SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, p := range results {
		pid := p["_id"].(primitive.ObjectID)
		mapped = append(mapped, gin.H{
			"Product id":        pid,
			"name":              p["name"],
			"short description": p["short_description"],
			"price per unit":    p["price_per_unit"],
			"unit":              p["unit"], // generic stub for array processing
			"product catagory":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand_name"],
			"photos":            p["photos"],
			"rating":            p["rating"],
			"discount":          p["discount"],
			"vender name":       "vendor name stub",
			"vender id":         p["vendor_id"],
			"iswishlisted":      CheckWishlist(c, pid),
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// GetProductByID handles /api/product/id
func GetProductByID(c *gin.Context) {
	productIDStr := c.Query("product id")
	if productIDStr == "" {
		productIDStr = c.PostForm("product id")
	}

	productID, _ := primitive.ObjectIDFromHex(productIDStr)

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var p bson.M
	err := coll.FindOne(ctx, bson.M{"_id": productID, "hidden": bson.M{"$ne": true}}).Decode(&p)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "product not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"id":                 p["_id"],
			"Name":               p["name"],
			"brand":              p["brand_name"],
			"short description":  p["short_description"],
			"price per unit":     p["price_per_unit"],
			"unit":               p["unit"],
			"product catagory":   p["product_category"],
			"delivary category":  p["delivery_category"],
			"stock":              p["stock"],
			"brand name":         p["brand_name"],
			"photos":             p["photos"],
			"rating":             p["rating"],
			"discount":           p["discount"],
			"vender name":        "stub",
			"vender id":          p["vendor_id"],
			"iswishlisted":       CheckWishlist(c, productID),
		},
	})
}

// GetRecommendedProducts handles /api/product/recommended
func GetRecommendedProducts(c *gin.Context) {
	// Simple recommendation algorithm pulling latest unhidden products
	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	opts := options.Find().SetLimit(15).SetSort(bson.M{"_id": -1})
	cursor, err := coll.Find(ctx, bson.M{"hidden": bson.M{"$ne": true}, "approved": true}, opts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, p := range results {
		pid := p["_id"].(primitive.ObjectID)
		mapped = append(mapped, gin.H{
			"Product id":        pid,
			"name":              p["name"],
			"short description": p["short_description"],
			"price per unit":    p["price_per_unit"],
			"unit":              p["unit"],
			"product catagory":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand_name"],
			"photos":            p["photos"],
			"rating":            p["rating"],
			"discount":          p["discount"],
			"vender name":       "vendor name stub",
			"vender id":         p["vendor_id"],
			"iswishlisted":      CheckWishlist(c, pid),
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}
