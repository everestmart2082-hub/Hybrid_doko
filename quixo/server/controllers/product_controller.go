package controllers

import (
	"context"
	"net/http"
	"strconv"
	"strings"
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
	if vendorIDStr == "" {
		vendorIDStr = c.Query("vendor id")
	}

	filter := bson.M{"hidden": bson.M{"$ne": true}}
	requireApproved := true

	if cat != "" {
		if oid, err := primitive.ObjectIDFromHex(cat); err == nil {
			filter["product_category"] = oid
		} else {
			filter["product_category"] = cat
		}
	}
	if vendorIDStr != "" {
		if vid, err := primitive.ObjectIDFromHex(vendorIDStr); err == nil {
			filter["vendor_id"] = vid
			// Logged-in vendor listing their own catalog: include pending/unapproved products.
			if selfID, ok := TryVendorHexIDFromBearer(c); ok && selfID == vendorIDStr {
				requireApproved = false
			}
		}
	}
	if requireApproved {
		filter["approved"] = true
	}

	if b := strings.TrimSpace(c.Query("brand name")); b != "" {
		filter["brand"] = bson.M{"$regex": b, "$options": "i"}
	}
	if s := strings.TrimSpace(c.Query("search text")); s != "" {
		filter["$or"] = []bson.M{
			{"name": bson.M{"$regex": s, "$options": "i"}},
			{"short_descriptions": bson.M{"$regex": s, "$options": "i"}},
		}
	}
	if mp := strings.TrimSpace(c.Query("min price")); mp != "" {
		if v, err := strconv.ParseFloat(mp, 64); err == nil {
			filter["price_per_unit"] = bson.M{"$gte": v}
		}
	}
	if xp := strings.TrimSpace(c.Query("max price")); xp != "" {
		if v, err := strconv.ParseFloat(xp, 64); err == nil {
			if ex, ok := filter["price_per_unit"].(bson.M); ok {
				ex["$lte"] = v
			} else {
				filter["price_per_unit"] = bson.M{"$lte": v}
			}
		}
	}
	switch strings.TrimSpace(c.Query("stock_status")) {
	case "in_stock":
		filter["stock"] = bson.M{"$gt": 0}
	case "out_of_stock":
		filter["stock"] = bson.M{"$lte": 0}
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
			"short description": p["short_descriptions"],
			"price per unit":    p["price_per_unit"],
			"unit":              p["unit"], // generic stub for array processing
			"product catagory":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand"],
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
			"brand":              p["brand"],
			"short description":  p["short_descriptions"],
			"price per unit":     p["price_per_unit"],
			"unit":               p["unit"],
			"product catagory":   p["product_category"],
			"delivary category":  p["delivery_category"],
			"stock":              p["stock"],
			"brand name":         p["brand"],
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
			"short description": p["short_descriptions"],
			"price per unit":    p["price_per_unit"],
			"unit":              p["unit"],
			"product catagory":  p["product_category"],
			"delivary category": p["delivery_category"],
			"stock":             p["stock"],
			"brand name":        p["brand"],
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
