package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
)

// CustomerHubCounts handles GET /api/user/hub-counts — cart lines, wishlist items, open order lines.
func CustomerHubCounts(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cartColl := utils.GetCollection("carts")
	wishColl := utils.GetCollection("wishlists")
	orderColl := utils.GetCollection("order")

	cartCount, _ := cartColl.CountDocuments(ctx, bson.M{"user_id": userID})
	wishCount, _ := wishColl.CountDocuments(ctx, bson.M{"user_id": userID})

	terminal := bson.M{"$in": []string{
		"delivered",
		"cancelledByUser",
		"cancelledbyuser",
		"cancelledByVendor",
		"cancelledbyvendor",
		"returned",
	}}
	openOrders, _ := orderColl.CountDocuments(ctx, bson.M{
		"user_id": userID,
		"status":  bson.M{"$nin": terminal},
	})

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"cart_items":   cartCount,
			"wishlist":     wishCount,
			"open_orders":  openOrders,
		},
	})
}
