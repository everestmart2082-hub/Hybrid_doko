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

// AdminProfileGet handles /api/admin/profile/get
func AdminProfileGet(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var admin models.Admin
	err := coll.FindOne(ctx, bson.M{"_id": adminID}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"name":    admin.Name,
			"number":  admin.Phone,
			"email":   admin.Email,
		},
	})
}

// AdminProfileUpdate handles /api/admin/profile/update
func AdminProfileUpdate(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	name := c.PostForm("name")
	number := c.PostForm("number")
	email := c.PostForm("email")

	coll := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	otp, _ := GenerateOTP()
	update := bson.M{
		"updation_requested": true,
		"updates_proposed": bson.M{
			"name":        name,
			"number":      number,
			"email": email,
		},
		"otp": otp,
	}

	_, err := coll.UpdateOne(ctx, bson.M{"_id": adminID}, bson.M{"$set": update})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// AdminProfileOTP handles /api/admin/profile/otp
func AdminProfileOTP(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	otp := c.PostForm("otp")

	coll := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var adminDoc bson.M
	err := coll.FindOne(ctx, bson.M{"_id": adminID, "otp": otp}).Decode(&adminDoc)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	proposed, ok := adminDoc["updates_proposed"].(bson.M)
	var updateQuery bson.M
	if !ok {
		updateQuery = bson.M{"$unset": bson.M{"otp": "", "updation_requested": "", "updates_proposed": ""}}
	} else {
		updateQuery = bson.M{
			"$set": bson.M{
				"name":  proposed["name"],
				"phone": proposed["number"],
				"email": proposed["email"],
			},
			"$unset": bson.M{
				"otp":                "",
				"updation_requested": "",
				"updates_proposed":   "",
			},
		}
	}

	_, err = coll.UpdateOne(ctx, bson.M{"_id": adminID}, updateQuery)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}

// AdminProfileDelete handles /api/admin/profile/delete
func AdminProfileDelete(c *gin.Context) {
	adminID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	reason := c.PostForm("reason")
	option := c.PostForm("options")

	coll := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if option == "delete" {
		_, err := coll.DeleteOne(ctx, bson.M{"_id": adminID})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
	} else {
		_, err := coll.UpdateOne(ctx, bson.M{"_id": adminID}, bson.M{"$set": bson.M{"suspended": true, "suspension_reason": reason}})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully paused/delete"})
}

// AdminProfileAddOTP handles /api/admin/profile/add/otp
func AdminProfileAddOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var admin models.Admin
	err := coll.FindOne(ctx, bson.M{"phone": phone, "otp": otp}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": admin.ID}, bson.M{"$unset": bson.M{"otp": ""}})
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}
