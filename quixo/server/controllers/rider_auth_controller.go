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

// RiderRegistration handles /api/rider/registration/
func RiderRegistration(c *gin.Context) {
	phone := c.PostForm("number")
	
	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var existing models.Rider
	err := coll.FindOne(ctx, bson.M{"number": phone}).Decode(&existing)
	if err == nil {
		if existing.Suspended {
			c.JSON(http.StatusOK, gin.H{"success": false, "message": "server error"}) // mimicing exact expected blocks
			return
		}
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "verify otp"})
		return
	}

	otp, _ := GenerateOTP()
	newRider := models.Rider{
		ID:                primitive.NewObjectID(),
		Name:              c.PostForm("name"),
		Number:            phone,
		Email:             c.PostForm("email"),
		RcBookFile:        c.PostForm("Rc Book file"),
		CitizenshipFile:   c.PostForm("Citizenship file"),
		PanCardFile:       c.PostForm("pan card file"),
		Address:           c.PostForm("Address"),
		BikeModel:         c.PostForm("bike model"),
		BikeNumber:        c.PostForm("bike number"),
		BikeColor:         c.PostForm("bike color"),
		Type:              c.PostForm("type"),
		BikeInsuranceFile: c.PostForm("bike insurance paper file"),
		OTP:               otp,
		Verified:          false,
		Suspended:         false,
	}

	_, err = coll.InsertOne(ctx, newRider)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// RiderRegistrationOTP handles /api/rider/registration/otp
func RiderRegistrationOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var rider models.Rider
	err := coll.FindOne(ctx, bson.M{"number": phone, "otp": otp}).Decode(&rider)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": rider.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, _ := GenerateJWT(rider.ID, "rider")
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "application submitted",
		"token":   token,
		"id":      rider.ID.Hex(),
	})
}

// RiderLogin handles /api/rider/login/
func RiderLogin(c *gin.Context) {
	phone := c.PostForm("phone")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var rider models.Rider
	err := coll.FindOne(ctx, bson.M{"number": phone}).Decode(&rider)
	if err != nil || rider.Suspended {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "server error"})
		return
	}

	otp, _ := GenerateOTP()
	coll.UpdateOne(ctx, bson.M{"_id": rider.ID}, bson.M{"$set": bson.M{"otp": otp}})

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// RiderLoginOTP handles /api/rider/login/otp
func RiderLoginOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var rider models.Rider
	err := coll.FindOne(ctx, bson.M{"number": phone, "otp": otp}).Decode(&rider)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": rider.ID}, bson.M{"$unset": bson.M{"otp": ""}})

	token, _ := GenerateJWT(rider.ID, "rider")
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "successfully logged in",
		"token":   token,
		"id":      rider.ID.Hex(),
	})
}
