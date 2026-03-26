package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// CustomerProfileGet handles /api/user/profile/get
func CustomerProfileGet(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "token has expire"})
		return
	}

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := coll.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil || user.Deactivate {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
		return
	}

	if user.Suspend {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account has been suspended + violation..."})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"name":            user.Name,
			"number":          user.Number,
			"email":           user.Email,
			"default address": "", // Address mappings not yet available inside standard customer schema
		},
	})
}

// CustomerProfileUpdate handles /api/user/profile/update
func CustomerProfileUpdate(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "token has expire"})
		return
	}

	number := c.PostForm("number")
	name := c.PostForm("name")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := coll.FindOne(ctx, bson.M{"_id": userID}).Decode(&user)
	if err != nil || user.Suspend || user.Deactivate {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "suspended account"})
		return
	}

	otp, _ := GenerateOTP()
	update := bson.M{
		"otp": otp,
		"updates_proposed": bson.M{
			"number": number,
			"name":   name,
		},
	}

	_, err = coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": update})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// CustomerProfileUpdateOTP handles /api/user/profile/otp
func CustomerProfileUpdateOTP(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "token has expire"})
		return
	}

	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user bson.M
	err := coll.FindOne(ctx, bson.M{"_id": userID, "otp": otp, "number": phone}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	// Dynamic schema mutation mapping from interim state 
	proposedUpdates, mapOk := user["updates_proposed"].(primitive.M)
	if mapOk {
		coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": proposedUpdates, "$unset": bson.M{"otp": "", "updates_proposed": ""}})
		c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully updated"})
	} else {
		// Fallback clean if empty
		coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$unset": bson.M{"otp": "", "updates_proposed": ""}})
		c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully updated"})
	}
}

// CustomerProfileDelete handles /api/user/profile/delete
func CustomerProfileDelete(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "token has expire"})
		return
	}

	option := c.PostForm("options")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if option == "delete" {
		coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": bson.M{"deactivate": true}})
	} else {
		coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": bson.M{"deactivate": true}})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully paused/delete"})
}
