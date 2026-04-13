package controllers

import (
	"context"
	"errors"
	"net/http"
	"strings"
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
		Phone string `json:"phone" form:"phone" binding:"required"`
	}

	var req LoginRequest
	// Flutter app sends multipart FormData; JSON clients are also supported.
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Only decode fields we need — avoids 500s when optional nested BSON (e.g. violations) does not match models.Vendor.
	type vendorLoginDoc struct {
		ID        primitive.ObjectID `bson:"_id"`
		Verified  bool               `bson:"verified"`
		Suspended bool               `bson:"suspended"`
	}
	var doc vendorLoginDoc
	err := collection.FindOne(ctx, bson.M{"number": req.Phone}).Decode(&doc)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "server error"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	if !doc.Verified || doc.Suspended {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account not verified or suspended"})
		return
	}

	otp, _ := GenerateOTP()
	_, err = collection.UpdateOne(ctx, bson.M{"_id": doc.ID}, bson.M{"$set": bson.M{"otp": otp}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// VendorOTPLogin handles /api/vender/login/otp
func VendorOTPLogin(c *gin.Context) {
	type OTPLoginRequest struct {
		Phone string `json:"phone" form:"phone" binding:"required"`
		OTP   string `json:"otp" form:"otp" binding:"required"`
	}

	var req OTPLoginRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}
	req.Phone = strings.TrimSpace(req.Phone)
	req.OTP = strings.TrimSpace(req.OTP)

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Match by phone then compare OTP with TrimSpace so we accept correct zero-padded OTPs and
	// legacy values that were padded with spaces (old fmt "%06s" bug).
	type vendorOtpDoc struct {
		ID        primitive.ObjectID `bson:"_id"`
		OTP       string             `bson:"otp"`
		Verified  bool               `bson:"verified"`
		Suspended bool               `bson:"suspended"`
	}
	var doc vendorOtpDoc
	err := collection.FindOne(ctx, bson.M{"number": req.Phone}).Decode(&doc)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	if strings.TrimSpace(doc.OTP) != req.OTP {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	if !doc.Verified || doc.Suspended {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account not verified or suspended"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": doc.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, err := GenerateJWT(doc.ID, "vendor")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"token":   token,
		"id":      doc.ID.Hex(),
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
		Phone string `json:"phone" form:"phone" binding:"required"`
		OTP   string `json:"otp" form:"otp" binding:"required"`
	}

	var req OTPRegRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}
	req.Phone = strings.TrimSpace(req.Phone)
	req.OTP = strings.TrimSpace(req.OTP)

	collection := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	type regOtpDoc struct {
		ID  primitive.ObjectID `bson:"_id"`
		OTP string             `bson:"otp"`
	}
	var regDoc regOtpDoc
	err := collection.FindOne(ctx, bson.M{"number": req.Phone}).Decode(&regDoc)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	if strings.TrimSpace(regDoc.OTP) != req.OTP {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	collection.UpdateOne(ctx, bson.M{"_id": regDoc.ID}, bson.M{"$unset": bson.M{"otp": ""}})
	emitRegistrationEvent(ctx, "vendor", regDoc.ID, true)

	token, err := GenerateJWT(regDoc.ID, "vendor")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "application submitted",
		"token":   token,
		"id":      regDoc.ID.Hex(),
	})
}
