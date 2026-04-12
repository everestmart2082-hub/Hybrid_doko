package controllers

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
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
	vendorIDVal, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}
	vid, ok := vendorIDVal.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, bson.M{
		"$or": []bson.M{
			{"target_id": vid, "type": "vendor"},
			{"user_id": vid},
		},
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

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": mapped,
	})
}

// VendorContactAdmin handles /api/vender/contact/admin (vendor → admin shared inbox).
func VendorContactAdmin(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "unauthorized"})
		return
	}
	name := c.PostForm("name")
	email := c.PostForm("email")
	message := c.PostForm("message")
	if message == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "message required"})
		return
	}
	vid, ok := vendorID.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	footer := fmt.Sprintf("Vendor account ID: %v", vendorID)
	if err := pushContactToAllAdmins(ctx, "vendor", name, email, message, footer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "message not sent"})
		return
	}
	if err := insertContactNotification(ctx, "vendor", message, vid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "message not sent"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "message sent successfully"})
}
