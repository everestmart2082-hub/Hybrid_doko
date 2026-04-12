package controllers

import (
	"context"
	"fmt"
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
		"user_id":   userID,
		"target_id": productID,
		"type":      "product",
		"rating":    rating,
		"date":      time.Now(),
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
		"user_id":   userID,
		"target_id": riderID,
		"type":      "rider",
		"rating":    rating,
		"date":      time.Now(),
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
		"user_id":     userID,
		"product_id":  productID,
		"message":     message,
		"description": message,
		"date":        time.Now(),
	}

	res, err := coll.InsertOne(ctx, item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	if rid, ok := res.InsertedID.(primitive.ObjectID); ok && !rid.IsZero() {
		pcoll := utils.GetCollection("products")
		_, _ = pcoll.UpdateOne(ctx, bson.M{"_id": productID}, bson.M{"$addToSet": bson.M{"review_ids": rid}})
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

	messageText := strings.TrimSpace(c.PostForm("message"))
	name := c.PostForm("name")
	email := c.PostForm("email")
	if messageText == "" {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "message required"})
		return
	}

	uid, ok := userID.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	footer := fmt.Sprintf("User ID: %v", userID)
	if err := pushContactToAllAdmins(ctx, "customer", name, email, messageText, footer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}
	if err := insertContactNotification(ctx, "customer", messageText, uid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}

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

	uid, ok := userID.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	// Admin pushes use type "user"; contact-us rows use "customer".
	cursor, err := coll.Find(ctx, bson.M{
		"target_id": uid,
		"type":      bson.M{"$in": []string{"user", "customer"}},
	}, options.Find().SetSort(bson.D{{Key: "date", Value: -1}}).SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	defer cursor.Close(ctx)

	mapped, err := cursorNotificationsToSlice(ctx, cursor)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}
