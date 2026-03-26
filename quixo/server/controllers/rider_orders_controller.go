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

// RiderOrderAll handles /api/rider/order/all
func RiderOrderAll(c *gin.Context) {
	riderID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	status := c.PostForm("status")

	filter := bson.M{"rider_id": riderID}
	if status != "" {
		filter["status"] = status
	}

	coll := utils.GetCollection("orders")
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
	for _, o := range results {
		mapped = append(mapped, gin.H{
			"order id":          o["_id"],
			"product category":  "CategoryStub",
			"order time":        o["date"],
			"product id":        "prod_id",
			"product number":    1,
		})
	}

	// Schema states nested orders in array wrapper format based directly on allOrder.txt
	wrapper := []interface{}{"orders id", mapped}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": wrapper})
}

// RiderGenerateOTP handles /api/rider/generate_otp
func RiderGenerateOTP(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("orders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	otp, _ := GenerateOTP()
	_, err := coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"delivery_otp": otp}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	// OTP generated to match user on drop-off.
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully generated otp"})
}

// RiderDeliverProduct handles /api/rider/order/delivered
func RiderDeliverProduct(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)
	otp := c.PostForm("otp")

	coll := utils.GetCollection("orders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var order bson.M
	err := coll.FindOne(ctx, bson.M{"_id": orderID, "delivery_otp": otp}).Decode(&order)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "server error"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "delivered"}, "$unset": bson.M{"delivery_otp": ""}})
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order delvered"}) // mimicking exact schema text
}

// RiderRejectOrder handles /api/rider/order/reject
func RiderRejectOrder(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("orders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "rejected", "rider_id": nil}}) 
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order rejected"})
}

// RiderAcceptOrder handles /api/rider/order/accept
func RiderAcceptOrder(c *gin.Context) {
	riderID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("orders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Update order strictly marking its tether manually to this specific rider
	_, err := coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "accepted", "rider_id": riderID}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order accepted"})
}

