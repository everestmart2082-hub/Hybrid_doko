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
	"go.mongodb.org/mongo-driver/mongo"
)

// AdminLogin handles /api/admin/Login/
func AdminLogin(c *gin.Context) {
	type LoginRequest struct {
		Phone string `json:"phone" binding:"required"`
	}

	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var admin models.Admin
	err := collection.FindOne(ctx, bson.M{"phone": req.Phone}).Decode(&admin)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	otp, _ := GenerateOTP()
	_, err = collection.UpdateOne(ctx, bson.M{"_id": admin.ID}, bson.M{"$set": bson.M{"otp": otp}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// AdminOTPLogin handles /api/admin/login/otp
func AdminOTPLogin(c *gin.Context) {
	type OTPLoginRequest struct {
		Phone string `json:"phone" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}

	var req OTPLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var admin models.Admin
	err := collection.FindOne(ctx, bson.M{"phone": req.Phone, "otp": req.OTP}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": admin.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, err := GenerateJWT(admin.ID, "admin")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
	})
}

// AdminAddAdmin handles /api/admin/addAdmin
func AdminAddAdmin(c *gin.Context) {
	name := c.PostForm("name")
	email := c.PostForm("email")
	number := c.PostForm("number")

	collection := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var existing models.Admin
	err := collection.FindOne(ctx, bson.M{"phone": number}).Decode(&existing)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"success": false, "message": "admin already exists"})
		return
	}

	otp, _ := GenerateOTP()
	newAdmin := models.Admin{
		ID:    primitive.NewObjectID(),
		Name:  name,
		Email: email,
		Phone: number,
		OTP:   otp,
	}

	_, err = collection.InsertOne(ctx, newAdmin)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// AdminAddAdminOTP handles /api/admin/addAdminOtp
func AdminAddAdminOTP(c *gin.Context) {
	type Request struct {
		Number string `json:"number" binding:"required"`
		OTP    string `json:"otp" binding:"required"`
	}

	var req Request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("admins")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var admin models.Admin
	err := collection.FindOne(ctx, bson.M{"phone": req.Number, "otp": req.OTP}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": admin.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, _ := GenerateJWT(admin.ID, "admin")

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
	})
}
