package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type CategoryField struct {
	Name        string `json:"name" bson:"name"`
	Description string `json:"description" bson:"description"`
	Hint        string `json:"hint" bson:"hint"`
}

type Category struct {
	ID       primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Name     string             `json:"name" bson:"name"`
	Type     string             `json:"type" bson:"type"` // quick or normal
	Required []CategoryField    `json:"required" bson:"required"`
	Others   []CategoryField    `json:"others" bson:"others"`
	Hidden   bool               `json:"hidden" bson:"hidden"`
}
