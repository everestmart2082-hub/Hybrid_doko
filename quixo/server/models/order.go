package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Order struct {
	ID             primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Status         string             `json:"status" bson:"status"`
	ProductID      primitive.ObjectID `json:"product_id" bson:"product_id"`
	Type           string             `json:"type" bson:"type"` // grocery / ecommerce
	DateOfOrder    time.Time          `json:"date_of_order" bson:"date_of_order"`
	DateOfDelivery time.Time          `json:"date_of_delivery" bson:"date_of_delivery"`
	RiderID        primitive.ObjectID `json:"rider_id,omitempty" bson:"rider_id,omitempty"`
}
