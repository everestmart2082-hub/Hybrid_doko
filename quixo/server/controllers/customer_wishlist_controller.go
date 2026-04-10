package controllers

import (
	"context"
	"net/http"
	"strings"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// CheckWishlist checks if a specific product is wishlisted natively by peeking at an optional authorization header.
// It rests here conceptually as it bridges Product fetches with Customer Wishlist entities.
func CheckWishlist(c *gin.Context, productID primitive.ObjectID) bool {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
		return false
	}

	tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
	claims, err := VerifyToken(tokenStr)
	if err != nil {
		return false
	}

	userIDHex, ok := claims["id"].(string)
	if !ok {
		return false
	}
	userID, _ := primitive.ObjectIDFromHex(userIDHex)

	coll := utils.GetCollection("wishlists")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	count, err := coll.CountDocuments(ctx, bson.M{"user_id": userID, "product_id": productID})
	if err != nil {
		return false
	}
	return count > 0
}

// CustomerAddToWishList handles /api/user/wishlist/add
func CustomerAddToWishList(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	productIDStr := c.PostForm("product id")
	productID, _ := primitive.ObjectIDFromHex(productIDStr)

	coll := utils.GetCollection("wishlists")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	item := bson.M{
		"user_id":    userID,
		"product_id": productID,
	}

	_, err := coll.InsertOne(ctx, item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	// Schema textual duplication check
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added to cart"})
}

// CustomerRemoveFromWishList handles /api/user/wishlist/remove
func CustomerRemoveFromWishList(c *gin.Context) {
	wishlistIDStr := c.PostForm("wishlist id")
	wishlistID, _ := primitive.ObjectIDFromHex(wishlistIDStr)

	coll := utils.GetCollection("wishlists")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.DeleteOne(ctx, bson.M{"_id": wishlistID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added to cart"}) // Mimics the copy-pasted schema spec format
}

// CustomerGetWishList handles /api/user/wishlist/get
func CustomerGetWishList(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("wishlists")
	productColl := utils.GetCollection("products")
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
	for _, w := range results {
		productID, _ := w["product_id"].(primitive.ObjectID)
		var product bson.M
		if err := productColl.FindOne(ctx, bson.M{"_id": productID, "hidden": bson.M{"$ne": true}}).Decode(&product); err != nil {
			continue
		}

		image := ""
		if photos, ok := product["photos"].(primitive.A); ok && len(photos) > 0 {
			if first, ok := photos[0].(string); ok {
				image = first
			}
		}

		mapped = append(mapped, gin.H{
			"wishlist id":       w["_id"],
			"product id":        w["product_id"],
			"name":              product["name"],
			"image":             image,
			"photos":            product["photos"],
			"number":            1,
			"priceperunit":      product["price_per_unit"],
			"discount":          product["discount"],
			"unit":              product["unit"],
			"delivary category": product["delivery_category"],
			"product category":  product["product_category"],
			"brandname":         product["brand"],
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}
