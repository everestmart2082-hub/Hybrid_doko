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

// CustomerAddToCart handles /api/user/cart/add
func CustomerAddToCart(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	productIDStr := c.PostForm("product id")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)
	numberStr := c.PostForm("number")
	qty, _ := strconv.Atoi(numberStr)

	coll := utils.GetCollection("carts")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cartItem := bson.M{
		"user_id":    userID,
		"product_id": productID,
		"number":     qty,
	}

	_, err := coll.InsertOne(ctx, cartItem)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added to cart"})
}

// CustomerGetCart handles /api/user/cart/get
func CustomerGetCart(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("carts")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, bson.M{"user_id": userID}, options.Find().SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, item := range results {
		mapped = append(mapped, gin.H{
			"cart id":           item["_id"],
			"product id":        item["product_id"],
			"name":              "Product Name", // Mocked product aggregation stub
			"image":             "url",
			"number":            item["number"],
			"priceperunit":      0,
			"unit":              "kg",
			"delivary category": "",
			"product category":  "",
			"brandname":         "",
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// CustomerRemoveFromCart handles /api/user/cart/remove
func CustomerRemoveFromCart(c *gin.Context) {
	cartIDStr := c.PostForm("cart id")
	cartID, _ := primitive.ObjectIDFromHex(cartIDStr)

	coll := utils.GetCollection("carts")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.DeleteOne(ctx, bson.M{"_id": cartID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}
