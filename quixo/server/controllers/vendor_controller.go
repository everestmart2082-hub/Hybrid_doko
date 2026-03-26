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

// VendorLogin handles /api/vender/login/
func VendorLogin(c *gin.Context) {
	type LoginRequest struct {
		Phone string `json:"phone" binding:"required"`
	}

	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var vendor models.Vendor
	err := collection.FindOne(ctx, bson.M{"number": req.Phone}).Decode(&vendor)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	if !vendor.Verified || vendor.Suspended {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account not verified or suspended"})
		return
	}

	otp, _ := GenerateOTP()
	_, err = collection.UpdateOne(ctx, bson.M{"_id": vendor.ID}, bson.M{"$set": bson.M{"otp": otp}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// VendorOTPLogin handles /api/vender/login/otp
func VendorOTPLogin(c *gin.Context) {
	type OTPLoginRequest struct {
		Phone string `json:"phone" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}

	var req OTPLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var vendor models.Vendor
	err := collection.FindOne(ctx, bson.M{"number": req.Phone, "otp": req.OTP}).Decode(&vendor)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	if !vendor.Verified || vendor.Suspended {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account not verified or suspended"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": vendor.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, err := GenerateJWT(vendor.ID, "vendor")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
		"id":      vendor.ID.Hex(),
	})
}

// VendorRegistration handles /api/vender/registration/
func VendorRegistration(c *gin.Context) {
	coll := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	name := c.PostForm("name")
	number := c.PostForm("number")
	
	// Check if vendor with this number already exists
	var existingVendor models.Vendor
	err := coll.FindOne(ctx, bson.M{"number": number}).Decode(&existingVendor)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"success": false, "message": "number already exists"})
		return
	}

	storeName := c.PostForm("storeName")
	address := c.PostForm("Address")
	email := c.PostForm("email")
	businessType := c.PostForm("Business Type")
	description := c.PostForm("Description")
	geolocation := c.PostForm("geolocation")

	panFile, err := c.FormFile("Pan file")
	var panFilePath string
	if err == nil {
		panFilePath, _ = utils.SaveUploadedFile(panFile)
	}

	otp, _ := GenerateOTP()

	vendor := models.Vendor{
		ID:           primitive.NewObjectID(),
		Name:         name,
		Number:       number,
		PanFile:      panFilePath,
		StoreName:    storeName,
		Address:      address,
		Email:        email,
		BusinessType: businessType,
		Description:  description,
		Geolocation:  geolocation,
		Verified:     false,
		Suspended:    false,
		Revenue:      0,
		OTP:          otp, // Store OTP to verify later
	}

	_, err = coll.InsertOne(ctx, vendor)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// VendorRegistrationOTP handles /api/vender/registration/otp
func VendorRegistrationOTP(c *gin.Context) {
	type OTPRegRequest struct {
		Phone string `json:"phone" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}

	var req OTPRegRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var vendor models.Vendor
	err := collection.FindOne(ctx, bson.M{"number": req.Phone, "otp": req.OTP}).Decode(&vendor)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": vendor.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, err := GenerateJWT(vendor.ID, "vendor")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "application submitted",
		"token":   token,
		"id":      vendor.ID.Hex(),
	})
}
