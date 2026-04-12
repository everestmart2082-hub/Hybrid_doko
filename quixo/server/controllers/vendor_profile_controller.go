package controllers

import (
	"context"
	"errors"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// VendorProfileUpdate handles /api/vender/profile/update
func VendorProfileUpdate(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	number := c.PostForm("number")
	name := c.PostForm("name")
	description := c.PostForm("description")
	address := c.PostForm("address")
	geolocation := c.PostForm("geolocation")

	updateProposed := models.VendorUpdateProposed{
		Name:        name,
		Address:     address,
		Description: description,
		Geolocation: geolocation,
	}

	coll := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	otp, _ := GenerateOTP()

	filter := bson.M{"_id": vendorID}
	update := bson.M{"$set": bson.M{
		"updation_requested": true,
		"updates_proposed":   updateProposed,
		"number":             number,
		"otp":                otp,
	}}

	_, err := coll.UpdateOne(ctx, filter, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify for otp"})
}

// VendorProfileUpdateOTP handles /api/vender/profile/otp
func VendorProfileUpdateOTP(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	filter := bson.M{"_id": vendorID, "otp": otp}
	if phone != "" {
		filter["number"] = phone
	}

	var vendor models.Vendor
	err := coll.FindOne(ctx, filter).Decode(&vendor)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "server error"})
		return
	}

	_, err = coll.UpdateOne(ctx, bson.M{"_id": vendorID}, bson.M{"$unset": bson.M{"otp": ""}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully applied for verification"})
}

// VendorProfileDelete handles /api/vender/profile/delete
func VendorProfileDelete(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	reason := c.PostForm("reason")
	if reason == "" {
		reason = c.Query("reason")
	}

	coll := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": vendorID}, bson.M{"$set": bson.M{"suspended": true, "messages": []models.Message{{Type: "Delete Request", Date: time.Now().String(), Description: reason}}}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully paused/delete"})
}

// vendorProfileDoc holds only scalar profile fields so BSON decode cannot fail on
// legacy or oddly-shaped nested arrays (e.g. violations) on otherwise valid vendors.
type vendorProfileDoc struct {
	ID           primitive.ObjectID `bson:"_id"`
	Name         string             `bson:"name"`
	Number       string             `bson:"number"`
	PanFile      string             `bson:"pan_file"`
	StoreName    string             `bson:"store_name"`
	Address      string             `bson:"address"`
	Email        string             `bson:"email"`
	BusinessType string             `bson:"business_type"`
	Description  string             `bson:"description"`
	Geolocation  string             `bson:"geolocation"`
	Message      string             `bson:"message"`
}

// VendorProfileGet handles POST /api/vender/profile
func VendorProfileGet(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("vendors")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var doc vendorProfileDoc
	err := coll.FindOne(ctx, bson.M{"_id": vendorID}).Decode(&doc)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			// Use 200 so HTTP clients (e.g. Dio default validateStatus) surface message, not a transport 404.
			c.JSON(http.StatusOK, gin.H{"success": false, "message": "vendor not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "success",
		"data": gin.H{
			"id":           doc.ID.Hex(),
			"name":         doc.Name,
			"number":       doc.Number,
			"storeName":    doc.StoreName,
			"Address":      doc.Address,
			"email":        doc.Email,
			"BusinessType": doc.BusinessType,
			"Description":  doc.Description,
			"geolocation":  doc.Geolocation,
			"Pan file":     doc.PanFile,
			"admin_message": doc.Message,
		},
	})
}
