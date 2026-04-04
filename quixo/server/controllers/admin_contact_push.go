package controllers

import (
	"context"
	"fmt"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"go.mongodb.org/mongo-driver/bson"
)

// pushContactToAllAdmins appends a message to every admin document (shared inbox).
func pushContactToAllAdmins(ctx context.Context, senderLabel, displayName, email, messageBody, footer string) error {
	coll := utils.GetCollection("admins")
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
		Type:        "contact",
		Date:        time.Now().Format(time.RFC3339),
		Description: desc,
	}
	_, err := coll.UpdateMany(ctx, bson.M{}, bson.M{"$push": bson.M{"messages": msg}})
	return err
}
