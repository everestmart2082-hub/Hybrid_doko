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

func notificationTypeForCollection(collName string) string {
	switch collName {
	case "users":
		return "user"
	case "vendors":
		return "vendor"
	case "riders":
		return "rider"
	default:
		return ""
	}
}

// Reusable Notification injector: pushes in-app message and records a notifications row.
func handleNotification(c *gin.Context, idField, collName string) {
	idStr := c.PostForm(idField)
	messageText := c.PostForm("message")
	targetID, err := primitive.ObjectIDFromHex(idStr)
	if err != nil || idStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid id"})
		return
	}

	coll := utils.GetCollection(collName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	msg := models.Message{
		Type:        "from_admin",
		Date:        time.Now().Format("2006-01-02 15:04:05"),
		Description: messageText,
	}

	_, err = coll.UpdateOne(ctx, bson.M{"_id": targetID}, bson.M{"$push": bson.M{"messages": msg}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	ncoll := utils.GetCollection("notifications")
	notif := models.Notification{
		ID:       primitive.NewObjectID(),
		Type:     notificationTypeForCollection(collName),
		Message:  messageText,
		TargetID: targetID,
		Date:     time.Now(),
		Received: false,
	}
	if _, insErr := ncoll.InsertOne(ctx, notif); insErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully deleted"})
}

func AdminVendorNotification(c *gin.Context) { handleNotification(c, "vender id", "vendors") }
func AdminUserNotification(c *gin.Context)   { handleNotification(c, "user id", "users") }
func AdminRiderNotification(c *gin.Context)  { handleNotification(c, "rider id", "riders") }

// Reusable array mutation handler for violations
func handleViolationUpdate(c *gin.Context, collName, idField string) {
	idStr := c.PostForm(idField)

	violations := c.PostFormArray("violations[]")
	if len(violations) == 0 {
		val := c.PostForm("violations")
		if val != "" {
			violations = append(violations, val)
		} else {
			violations = []string{}
		}
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

func AdminVendorViolation(c *gin.Context)   { handleViolationUpdate(c, "vendors", "vender id") }
func AdminEmployeeViolation(c *gin.Context) { handleViolationUpdate(c, "employees", "employee id") }
func AdminRiderViolation(c *gin.Context)    { handleViolationUpdate(c, "riders", "rider id") }
func AdminUserViolation(c *gin.Context)     { handleViolationUpdate(c, "users", "user id") }
