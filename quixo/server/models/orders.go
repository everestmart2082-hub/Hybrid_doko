package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Orders struct {
	ID             primitive.ObjectID   `json:"id,omitempty" bson:"_id,omitempty"`
	OrderIDs       []primitive.ObjectID `json:"order_ids" bson:"order_ids"`
	UserID         primitive.ObjectID   `json:"user_id" bson:"user_id"`
	DeliveryCharge float64              `json:"delivery_charge" bson:"delivery_charge"`
	Total          float64              `json:"total" bson:"total"`
	OTP            string               `json:"otp" bson:"otp"`
	Status         string               `json:"status" bson:"status"` // ongoing / completed
}
