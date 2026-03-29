package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

// VendorBusinessTypes handles /api/vendor/businessTypes
func VendorBusinessTypes(c *gin.Context) {
	coll := utils.GetCollection("constants")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var constant models.Constant
	err := coll.FindOne(ctx, bson.M{"name": "Business type"}).Decode(&constant)

	data := []gin.H{}
	if err == nil {
		// Map the slice of strings into the requested object array [{id: 1, name: "textile"}]
		for i, name := range constant.TypesList {
			data = append(data, gin.H{"id": i + 1, "name": name})
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "business types fetched successfully",
		"data":    data,
	})
}

// VendorChartMonth handles /api/vendor/chart/month
func VendorChartMonth(c *gin.Context) {
	_, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"chart": gin.H{
			"day":     "2023-10-01",
			"revenue": 5000,
			"orders":  12,
		},
	})
}

// VendorNotification handles /api/vender/notification
func VendorNotification(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, bson.M{"user_id": vendorID})
	var results []bson.M
	if err == nil {
		cursor.All(ctx, &results)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": results,
	})
}

