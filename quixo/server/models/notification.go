package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Notification struct {
	ID         primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Type       string             `json:"type" bson:"type"`
	Message    string             `json:"message" bson:"message"`
	TargetID   primitive.ObjectID `json:"target_id" bson:"target_id"`
	Date       time.Time          `json:"date" bson:"date"`
	Received   bool               `json:"received" bson:"received"`
}
