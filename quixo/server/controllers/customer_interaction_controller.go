package controllers

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// CustomerProductRating handles /api/user/product/rating
func CustomerProductRating(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	productIDStr := c.PostForm("product id")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)
	ratingStr := c.PostForm("rating")
	rating, _ := strconv.Atoi(ratingStr)

	coll := utils.GetCollection("ratings")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	item := bson.M{
		"user_id":    userID,
		"target_id":  productID,
		"type":       "product",
		"rating":     rating,
		"date":       time.Now(),
	}

	_, err := coll.InsertOne(ctx, item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// CustomerRiderRating handles /api/user/rider/rating
func CustomerRiderRating(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	riderIDStr := c.PostForm("rider id")
	riderID, _ := primitive.ObjectIDFromHex(riderIDStr)
	ratingStr := c.PostForm("rating")
	rating, _ := strconv.Atoi(ratingStr)

	coll := utils.GetCollection("ratings")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	item := bson.M{
		"user_id":    userID,
		"target_id":  riderID,
		"type":       "rider",
		"rating":     rating,
		"date":       time.Now(),
	}

	_, err := coll.InsertOne(ctx, item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// CustomerReview handles /api/user/review
func CustomerReview(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	productIDStr := c.PostForm("product id")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)
	message := c.PostForm("message")

	coll := utils.GetCollection("reviews")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	item := bson.M{
		"user_id":    userID,
		"product_id": productID,
		"message":    message,
		"date":       time.Now(),
	}

	_, err := coll.InsertOne(ctx, item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// CustomerSendMessage handles /api/user/sendmessage
func CustomerSendMessage(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "message not sent"})
		return
	}

	messageText := c.PostForm("message")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	msg := models.Message{
		Type:        "to_admin",
		Date:        time.Now().String(),
		Description: messageText,
	}

	_, err := coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$push": bson.M{"messages": msg}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}

	// Native Spec format
	c.JSON(http.StatusOK, gin.H{"status": true, "message": "message sent successfully"})
}

// CustomerNotification handles /api/user/notification
func CustomerNotification(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Look natively using the notification mechanism injected during the Admin implementation
	cursor, err := coll.Find(ctx, bson.M{"target_id": userID, "type": "user"}, options.Find().SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []models.Notification
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, n := range results {
		mapped = append(mapped, gin.H{
			"message": n.Message,
			"date":    n.Date.String(),
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}
