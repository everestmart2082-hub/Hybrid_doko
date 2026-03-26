package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Log struct {
	ID      primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Type    string             `json:"type" bson:"type"` // Customer/Admin/Vendor/rider
	Message string             `json:"message" bson:"message"`
	Date    time.Time          `json:"date" bson:"date"`
}
