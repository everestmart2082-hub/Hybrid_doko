package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func bsonSliceToStrings(v interface{}) []string {
	if v == nil {
		return nil
	}
	switch x := v.(type) {
	case primitive.A:
		out := make([]string, 0, len(x))
		for _, e := range x {
			if s, ok := e.(string); ok {
				out = append(out, s)
			}
		}
		return out
	case []string:
		return x
	case []interface{}:
		out := make([]string, 0, len(x))
		for _, e := range x {
			out = append(out, fmt.Sprint(e))
		}
		return out
	default:
		return nil
	}
}

// VendorProductAdd handles /api/vender/product/add
func VendorProductAdd(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "unauthorized"})
		return
	}

	name := c.PostForm("Name")
	brand := c.PostForm("brand")
	description := c.PostForm("description")
	shortDesc := c.PostForm("short descriptions")
	pricePerUnitStr := c.PostForm("price per unit")
	unit := c.PostForm("unit")
	discountStr := c.PostForm("discount")
	productCategoryStr := c.PostForm("product catagory")
	deliveryCategory := c.PostForm("delivary category")
	if deliveryCategory == "" {
		deliveryCategory = c.PostForm("delivery category")
	}
	stockStr := c.PostForm("stock")

	pricePerUnit, _ := strconv.ParseFloat(pricePerUnitStr, 64)
	discount, _ := strconv.ParseFloat(discountStr, 64)
	stock, _ := strconv.Atoi(stockStr)
	productCategory, _ := primitive.ObjectIDFromHex(productCategoryStr)

	var photoPaths []string
	form, err := c.MultipartForm()
	if err == nil {
		files := form.File["Photos"]
		for _, file := range files {
			path, err := utils.SaveUploadedFile(file)
			if err == nil {
				photoPaths = append(photoPaths, path)
			}
		}
	}

	product := models.Product{
		ID:                primitive.NewObjectID(),
		Name:              name,
		Brand:             brand,
		ShortDescriptions: shortDesc,
		Description:       description,
		PricePerUnit:      pricePerUnit,
		Unit:              unit,
		Discount:          discount,
		ProductCategory:   productCategory,
		DeliveryCategory:  deliveryCategory,
		Stock:             stock,
		Photos:            photoPaths,
		VendorID:          vendorID.(primitive.ObjectID),
		Rating:            0,
		Approved:          false, // "submitted for verification"
		Hidden:            false,
	}

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err = coll.InsertOne(ctx, product)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully submitted for verification"})
}

// VendorProductEdit handles /api/vender/product/edit
func VendorProductEdit(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "unauthorized"})
		return
	}

	productIDStr := c.PostForm("product id")
	productID, err := primitive.ObjectIDFromHex(productIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid product id"})
		return
	}

	name := c.PostForm("Name")
	brand := c.PostForm("brand")
	description := c.PostForm("description")
	shortDesc := c.PostForm("short descriptions")
	pricePerUnitStr := c.PostForm("price per unit")
	unit := c.PostForm("unit")
	discountStr := c.PostForm("discount")
	productCategoryStr := c.PostForm("product catagory")
	deliveryCategory := c.PostForm("delivary category")
	if deliveryCategory == "" {
		deliveryCategory = c.PostForm("delivery category")
	}
	stockStr := c.PostForm("stock")

	pricePerUnit, _ := strconv.ParseFloat(pricePerUnitStr, 64)
	discount, _ := strconv.ParseFloat(discountStr, 64)
	stock, _ := strconv.Atoi(stockStr)
	productCategory, _ := primitive.ObjectIDFromHex(productCategoryStr)

	var photoPaths []string
	form, err := c.MultipartForm()
	if err == nil {
		files := form.File["Photos"]
		for _, file := range files {
			path, err := utils.SaveUploadedFile(file)
			if err == nil {
				photoPaths = append(photoPaths, path)
			}
		}
	}

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	filter := bson.M{"_id": productID, "vendor_id": vendorID}
	var existing bson.M
	if err := coll.FindOne(ctx, filter).Decode(&existing); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "product not found"})
		return
	}
	if len(photoPaths) == 0 {
		photoPaths = bsonSliceToStrings(existing["photos"])
	}

	updateProposed := models.ProductUpdateProposed{
		Name:              name,
		Brand:             brand,
		ShortDescriptions: shortDesc,
		Description:       description,
		PricePerUnit:      pricePerUnit,
		Unit:              unit,
		Discount:          discount,
		ProductCategory:   productCategory,
		DeliveryCategory:  deliveryCategory,
		Stock:             stock,
		Photos:            photoPaths,
		VendorID:          vendorID.(primitive.ObjectID),
	}

	update := bson.M{"$set": bson.M{
		"submitted_for_update": true,
		"updates_proposed":     updateProposed,
	}}

	result, err := coll.UpdateOne(ctx, filter, update)
	if err != nil || result.MatchedCount == 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully submitted for update verification"})
}

// VendorProductDelete handles /api/vender/product/delete
func VendorProductDelete(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "unauthorized"})
		return
	}

	productIDStr := c.Query("product id")
	productID, err := primitive.ObjectIDFromHex(productIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid product id"})
		return
	}

	coll := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	filter := bson.M{"_id": productID, "vendor_id": vendorID}
	update := bson.M{"$set": bson.M{
		"submitted_for_deletion": true,
	}}

	result, err := coll.UpdateOne(ctx, filter, update)
	if err != nil || result.MatchedCount == 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully submitted for deletion"})
}
