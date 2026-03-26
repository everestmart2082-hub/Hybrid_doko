package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// VendorOrderAll handles /api/vender/order/all
func VendorOrderAll(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("products") // Example placeholder join
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{"vendor_id": vendorID})
	var results []bson.M
	cursor.All(ctx, &results)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": []gin.H{}, // Currently returning an empty subset based on text file formatting suggestion
	})
}

// VendorOrderPrepared handles /api/vender/order/prepared/
func VendorOrderPrepared(c *gin.Context) {
	_, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	orderIDStr := c.PostForm("order id")
	orderID, err := primitive.ObjectIDFromHex(orderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err = coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "prepared"}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order prepared"})
}
