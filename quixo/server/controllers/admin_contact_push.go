package controllers

import (
	"context"
	"fmt"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// pushContactToAllAdmins appends a message to every admin document (shared inbox).
// msgType categorizes the inbox for the admin UI: contact | order | product | register | (anything else → Others).
func pushContactToAllAdmins(ctx context.Context, senderLabel, displayName, email, messageBody, footer string, msgType ...string) error {
	coll := utils.GetCollection("admins")
	t := "contact"
	if len(msgType) > 0 && msgType[0] != "" {
		t = msgType[0]
	}
	desc := messageBody
	if footer != "" {
		desc = fmt.Sprintf("%s\n\n%s", messageBody, footer)
	}
	if displayName != "" || email != "" {
		desc = fmt.Sprintf("[%s] %s <%s>\n\n%s", senderLabel, displayName, email, desc)
	} else {
		desc = fmt.Sprintf("[%s]\n\n%s", senderLabel, desc)
	}
	msg := models.Message{
		Type:        t,
		Date:        time.Now().Format(time.RFC3339),
		Description: desc,
	}
	_, err := coll.UpdateMany(ctx, bson.M{}, bson.M{"$push": bson.M{"messages": msg}})
	return err
}

// insertContactNotification stores a notifications collection row for the admin app (Contact tab).
// notifType must be vendor | customer | rider to match sender role.
func insertContactNotification(ctx context.Context, notifType, message string, targetID primitive.ObjectID) error {
	if notifType == "" || targetID.IsZero() {
		return nil
	}
	ncoll := utils.GetCollection("notifications")
	_, err := ncoll.InsertOne(ctx, bson.M{
		"_id":        primitive.NewObjectID(),
		"type":       notifType,
		"message":    message,
		"target_id":  targetID,
		"date":       time.Now(),
		"received":   false,
		"category":   "contact",
	})
	return err
}
