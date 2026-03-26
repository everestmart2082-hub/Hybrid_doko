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

// CustomerAddAddress handles /api/user/address/add
func CustomerAddAddress(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	label := c.PostForm("label")
	city := c.PostForm("city")
	state := c.PostForm("state")
	pincode := c.PostForm("pincode")
	landmark := c.PostForm("landmark")
	phone := c.PostForm("phone number")
	email := c.PostForm("email")

	coll := utils.GetCollection("addresses")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	address := bson.M{
		"user_id":      userID,
		"label":        label,
		"city":         city,
		"state":        state,
		"pincode":      pincode,
		"landmark":     landmark,
		"phone number": phone,
		"email":        email,
		"default":      false,
	}

	_, err := coll.InsertOne(ctx, address)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// CustomerGetAllAddress handles /api/user/address/all
func CustomerGetAllAddress(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("addresses")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, bson.M{"user_id": userID}, options.Find().SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "failed to fetch address"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, a := range results {
		mapped = append(mapped, gin.H{
			"address id":   a["_id"],
			"label":        a["label"],
			"city":         a["city"],
			"state":        a["state"],
			"pincode":      a["pincode"],
			"landmark":     a["landmark"],
			"phone number": a["phone number"],
			"email":        a["email"],
			"default":      a["default"],
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// CustomerUpdateAddress handles /api/user/address/update
func CustomerUpdateAddress(c *gin.Context) {
	addressIDStr := c.PostForm("address id")
	addressID, _ := primitive.ObjectIDFromHex(addressIDStr)

	label := c.PostForm("label")
	city := c.PostForm("city")
	state := c.PostForm("state")
	pincode := c.PostForm("pincode")
	landmark := c.PostForm("landmark")
	phone := c.PostForm("phone number")
	email := c.PostForm("email")

	coll := utils.GetCollection("addresses")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	update := bson.M{
		"label":        label,
		"city":         city,
		"state":        state,
		"pincode":      pincode,
		"landmark":     landmark,
		"phone number": phone,
		"email":        email,
	}

	res, err := coll.UpdateOne(ctx, bson.M{"_id": addressID}, bson.M{"$set": update})
	if err != nil || res.MatchedCount == 0 {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "not available"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully updated"})
}

// CustomerDeleteAddress handles /api/user/address/delete
func CustomerDeleteAddress(c *gin.Context) {
	addressIDStr := c.PostForm("address id")
	addressID, _ := primitive.ObjectIDFromHex(addressIDStr)

	coll := utils.GetCollection("addresses")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	res, err := coll.DeleteOne(ctx, bson.M{"_id": addressID})
	if err != nil || res.DeletedCount == 0 {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "not available"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully deleted"})
}
