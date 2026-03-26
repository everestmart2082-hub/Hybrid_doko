package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Review struct {
	ID          primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	UserID      primitive.ObjectID `json:"user_id" bson:"user_id"`
	ProductID   primitive.ObjectID `json:"product_id" bson:"product_id"`
	Description string             `json:"description" bson:"description"`
}
