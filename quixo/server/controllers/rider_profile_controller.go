package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// RiderProfileGet handles /api/rider/profile/get
func RiderProfileGet(c *gin.Context) {
	riderID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "token has expire"})
		return
	}

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var r models.Rider
	err := coll.FindOne(ctx, bson.M{"_id": riderID}).Decode(&r)
	if err != nil || r.Suspended {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "account has been suspended + violation..."})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"name":                      r.Name,
			"number":                    r.Number,
			"email":                     r.Email,
			"rating":                    r.Rating,
			"Rc Book file":              r.RcBookFile,
			"Citizenship file":          r.CitizenshipFile,
			"pan card file":             r.PanCardFile,
			"Address":                   r.Address,
			"bike model":                r.BikeModel,
			"bike number":               r.BikeNumber,
			"bike color":                r.BikeColor,
			"type":                      r.Type,
			"bike insurance paper file": r.BikeInsuranceFile,
			"verified":                  r.Verified,
			"updation requested":        r.UpdationRequested,
			"suspended":                 r.Suspended,
			"revenue":                   r.Revenue,
			"violations":                r.Violations,
			"admin_message":             r.Message,
		},
	})
}

// RiderProfileUpdate handles /api/rider/profile/update
func RiderProfileUpdate(c *gin.Context) {
	riderID, _ := c.Get("userID")

	number := c.PostForm("number")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	otp, _ := GenerateOTP()
	updates := bson.M{
		"otp": otp,
		"updates_proposed": bson.M{
			"number":          number,
			"description":     c.PostForm("description"),
			"default address": c.PostForm("default address"),
		},
	}

	_, err := coll.UpdateOne(ctx, bson.M{"_id": riderID}, bson.M{"$set": updates})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "verify otp"})
}

// RiderProfileOTP handles /api/rider/profile/otp
func RiderProfileOTP(c *gin.Context) {
	riderID, _ := c.Get("userID")

	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var rider bson.M
	err := coll.FindOne(ctx, bson.M{"_id": riderID, "otp": otp, "number": phone}).Decode(&rider)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	// Schema logic sets updation requested until admin manually validates
	proposedUpdates, _ := rider["updates_proposed"].(primitive.M)
	coll.UpdateOne(ctx, bson.M{"_id": riderID}, bson.M{"$set": bson.M{"updation_requested": true, "updates_proposed": proposedUpdates}, "$unset": bson.M{"otp": ""}})
	if rid, ok := riderID.(primitive.ObjectID); ok {
		emitProfileUpdateRequestedEvent(ctx, "rider", rid, true)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully sent for updation"})
}

// RiderProfileDelete handles /api/rider/profile/delete
func RiderProfileDelete(c *gin.Context) {
	riderID, _ := c.Get("userID")
	// option := c.PostForm("options")

	coll := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	coll.UpdateOne(ctx, bson.M{"_id": riderID}, bson.M{"$set": bson.M{"suspended": true}})

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully submitted for ..."})
}

// RiderDashboard handles /api/rider/dashboard
func RiderDashboard(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"earning":                1000,
			"order delivered number": 5,
			"order ongoing number":   1,
		},
	})
}

// RiderNotification handles /api/rider/notification
func RiderNotification(c *gin.Context) {
	riderIDVal, ok := c.Get("userID")
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}
	rid, ok := riderIDVal.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, bson.M{"target_id": rid, "type": "rider"},
		options.Find().SetSort(bson.D{{Key: "date", Value: -1}}).SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	defer cursor.Close(ctx)

	mapped, err := cursorNotificationsToSlice(ctx, cursor)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// RiderSendMessage handles /api/rider/sendmessage
func RiderSendMessage(c *gin.Context) {
	riderID, ok := c.Get("userID")
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"status": false, "message": "message not sent"})
		return
	}
	rid, ok := riderID.(primitive.ObjectID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}

	messageText := strings.TrimSpace(c.PostForm("message"))
	name := c.PostForm("name")
	email := c.PostForm("email")
	if messageText == "" {
		c.JSON(http.StatusBadRequest, gin.H{"status": false, "message": "message required"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	footer := fmt.Sprintf("Rider ID: %v", riderID)
	if err := pushContactToAllAdmins(ctx, "rider", name, email, messageText, footer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}
	if err := insertContactNotification(ctx, "rider", messageText, rid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": false, "message": "message not sent"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": true, "message": "message sent successfully"})
}
