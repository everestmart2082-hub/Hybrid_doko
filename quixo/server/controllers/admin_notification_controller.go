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

// Reusable Notification injector
func handleNotification(c *gin.Context, idField, targetRole string) {
	idStr := c.PostForm(idField)
	messageText := c.PostForm("message")
	targetID, _ := primitive.ObjectIDFromHex(idStr)

	coll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	notif := models.Notification{
		ID:       primitive.NewObjectID(),
		Type:     targetRole,
		Message:  messageText,
		TargetID: targetID,
		Date:     time.Now(),
		Received: false,
	}

	_, err := coll.InsertOne(ctx, notif)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	// According to spec definitions, there's a strict copy-pasted textual error where it wants "successfully deleted"
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully deleted"})
}

func AdminVendorNotification(c *gin.Context) { handleNotification(c, "vender id", "vendor") }
func AdminUserNotification(c *gin.Context) { handleNotification(c, "user id", "user") }
func AdminRiderNotification(c *gin.Context) { handleNotification(c, "rider id", "rider") }

// Reusable array mutation handler for violations
func handleViolationUpdate(c *gin.Context, collName, idField string) {
	idStr := c.PostForm(idField)
	
	// Form arrays typically bind as slice
	violations := c.PostFormArray("violations[]")
	if len(violations) == 0 {
		violations = append(violations, c.PostForm("violations"))
	}
	id, _ := primitive.ObjectIDFromHex(idStr)

	coll := utils.GetCollection(collName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{"violations": violations}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully updated"})
}

func AdminVendorViolation(c *gin.Context) { handleViolationUpdate(c, "vendors", "vender id") }
func AdminEmployeeViolation(c *gin.Context) { handleViolationUpdate(c, "employees", "employee id") }
func AdminRiderViolation(c *gin.Context) { handleViolationUpdate(c, "riders", "rider id") }
func AdminUserViolation(c *gin.Context) { handleViolationUpdate(c, "users", "user id") }
