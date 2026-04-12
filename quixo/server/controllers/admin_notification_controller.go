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
	"go.mongodb.org/mongo-driver/mongo/options"
)

// priorScalarMessageString returns the existing top-level "message" string if it is stored as a string.
// Legacy docs may omit it or use another BSON type; we skip appending in that case so notify still works.
func priorScalarMessageString(v interface{}) (string, bool) {
	if v == nil {
		return "", false
	}
	s, ok := v.(string)
	return s, ok
}

// asMessagesArray copies an existing BSON messages field into a new array.
// If the field is missing, null, or not an array (common legacy data), returns an empty array so updates never fail.
func asMessagesArray(v interface{}) bson.A {
	if v == nil {
		return bson.A{}
	}
	switch x := v.(type) {
	case bson.A:
		out := make(bson.A, len(x))
		copy(out, x)
		return out
	case []interface{}:
		out := make(bson.A, len(x))
		copy(out, x)
		return out
	default:
		return bson.A{}
	}
}

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

// handleNotification updates vendors, users, or riders (collName) the same way:
// appends to messages[], concatenates scalar message, and inserts a notifications row.
func handleNotification(c *gin.Context, idField, collName string) {
	idStr := c.PostForm(idField)
	messageText := strings.TrimSpace(c.PostForm("message"))
	if messageText == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "message required"})
		return
	}
	targetID, err := primitive.ObjectIDFromHex(idStr)
	if err != nil || idStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid id"})
		return
	}

	coll := utils.GetCollection(collName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var raw bson.M
	if err := coll.FindOne(ctx, bson.M{"_id": targetID}).Decode(&raw); err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	combined := messageText
	if prev, ok := priorScalarMessageString(raw["message"]); ok {
		if s := strings.TrimSpace(prev); s != "" {
			combined = s + "\n\n" + messageText
		}
	}

	msg := models.Message{
		Type:        "from_admin",
		Date:        time.Now().Format("2006-01-02 15:04:05"),
		Description: messageText,
	}

	// $push fails if `messages` is null or non-array. Replace the array in one $set instead.
	messages := asMessagesArray(raw["messages"])
	msgBytes, err := bson.Marshal(msg)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	var msgDoc bson.M
	if err := bson.Unmarshal(msgBytes, &msgDoc); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	messages = append(messages, msgDoc)

	_, err = coll.UpdateOne(ctx, bson.M{"_id": targetID}, bson.M{
		"$set": bson.M{
			"messages": messages,
			"message":  combined,
		},
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	ncoll := utils.GetCollection("notifications")
	doc := bson.M{
		"_id":        primitive.NewObjectID(),
		"type":       notificationTypeForCollection(collName),
		"message":    messageText,
		"target_id":  targetID,
		"date":       time.Now(),
		"received":   false,
		"category":   "admin_push",
		"from_admin": true,
	}
	if _, insErr := ncoll.InsertOne(ctx, doc); insErr != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "notification sent"})
}

func AdminVendorNotification(c *gin.Context) { handleNotification(c, "vender id", "vendors") }
func AdminUserNotification(c *gin.Context)   { handleNotification(c, "user id", "users") }
func AdminRiderNotification(c *gin.Context)  { handleNotification(c, "rider id", "riders") }

// AdminNotificationsAll returns recent rows from the notifications collection (admin inbox / audit).
func AdminNotificationsAll(c *gin.Context) {
	ncoll := utils.GetCollection("notifications")
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	cursor, err := ncoll.Find(ctx, bson.M{}, options.Find().
		SetSort(bson.D{{Key: "date", Value: -1}}).
		SetLimit(500))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	defer cursor.Close(ctx)

	var items []models.Notification
	if err := cursor.All(ctx, &items); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	out := make([]gin.H, 0, len(items))
	for _, n := range items {
		dateStr := ""
		if !n.Date.IsZero() {
			dateStr = n.Date.UTC().Format(time.RFC3339)
		}
		out = append(out, gin.H{
			"id":         n.ID.Hex(),
			"type":       n.Type,
			"message":    n.Message,
			"target_id":  n.TargetID.Hex(),
			"date":       dateStr,
			"received":   n.Received,
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": out})
}

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
