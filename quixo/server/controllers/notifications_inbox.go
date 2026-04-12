package controllers

import (
	"context"
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// cursorNotificationsToSlice decodes notification docs without models.Notification so odd BSON never 500s.
func cursorNotificationsToSlice(ctx context.Context, cur *mongo.Cursor) ([]gin.H, error) {
	var raw []bson.M
	if err := cur.All(ctx, &raw); err != nil {
		return nil, err
	}
	out := make([]gin.H, 0, len(raw))
	for _, doc := range raw {
		out = append(out, gin.H{
			"message": notificationMessageString(doc["message"]),
			"date":    formatBSONDateRFC3339(doc["date"]),
		})
	}
	return out, nil
}

func notificationMessageString(v interface{}) string {
	if v == nil {
		return ""
	}
	if s, ok := v.(string); ok {
		return s
	}
	return fmt.Sprint(v)
}

func formatBSONDateRFC3339(v interface{}) string {
	switch t := v.(type) {
	case time.Time:
		if t.IsZero() {
			return ""
		}
		return t.UTC().Format(time.RFC3339)
	case primitive.DateTime:
		return t.Time().UTC().Format(time.RFC3339)
	default:
		return ""
	}
}
