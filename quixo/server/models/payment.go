package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Payment struct {
	ID            primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Type          string             `json:"type" bson:"type"`
	TransactionID string             `json:"transaction_id,omitempty" bson:"transaction_id,omitempty"`
	Amount        float64            `json:"amount" bson:"amount"`
	OrderID       primitive.ObjectID `json:"order_id" bson:"order_id"`
}
