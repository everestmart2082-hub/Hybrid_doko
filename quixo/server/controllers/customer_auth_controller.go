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
)

// CustomerRegistration handles /api/user/registration/
func CustomerRegistration(c *gin.Context) {
	phone := c.PostForm("phone")
	email := c.PostForm("email")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var existingUser models.User
	err := coll.FindOne(ctx, bson.M{"number": phone}).Decode(&existingUser)
	if err == nil {
		if existingUser.Suspend {
			c.JSON(http.StatusOK, gin.H{"success": false, "message": "suspended account"})
			return
		}
		if existingUser.Deactivate {
			// Reactivation sequence
			otp, _ := GenerateOTP()
			coll.UpdateOne(ctx, bson.M{"_id": existingUser.ID}, bson.M{"$set": bson.M{"otp": otp}})
			c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "already registered"})
		return
	}

	otp, _ := GenerateOTP()
	newUser := models.User{
		ID:         primitive.NewObjectID(),
		Name:       c.PostForm("name"),
		Number:     phone,
		Email:      email,
		Suspend:    false,
		Deactivate: false,
		OTP:        otp,
	}

	_, err = coll.InsertOne(ctx, newUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// CustomerRegistrationOTP handles /api/user/registration/otp
func CustomerRegistrationOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := coll.FindOne(ctx, bson.M{"number": phone, "otp": otp}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	// Reactivate unsets the flag
	coll.UpdateOne(ctx, bson.M{"_id": user.ID}, bson.M{"$unset": bson.M{"otp": ""}, "$set": bson.M{"deactivate": false}})

	_ = pushContactToAllAdmins(ctx, "customer", user.Name, user.Email, "New customer completed registration (OTP verified).", fmt.Sprintf("User ID: %s", user.ID.Hex()), "register")

	token, _ := GenerateJWT(user.ID, "user") // specific rule user
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
		"id":      user.ID.Hex(),
	})
}

// CustomerLogin handles /api/user/login/
func CustomerLogin(c *gin.Context) {
	phone := c.PostForm("phone")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := coll.FindOne(ctx, bson.M{"number": phone}).Decode(&user)
	if err != nil || user.Deactivate {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "not registered"}) 
		return
	}

	if user.Suspend {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "suspended account"})
		return
	}

	otp, _ := GenerateOTP()
	coll.UpdateOne(ctx, bson.M{"_id": user.ID}, bson.M{"$set": bson.M{"otp": otp}})
	
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// CustomerLoginOTP handles /api/user/login/otp
func CustomerLoginOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := coll.FindOne(ctx, bson.M{"number": phone, "otp": otp}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	if user.Suspend {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "suspended account"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": user.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, _ := GenerateJWT(user.ID, "user")
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
		"id":      user.ID.Hex(),
	})
}
