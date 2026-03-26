package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Constant struct {
	ID        primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Name      string             `json:"name" bson:"name"`
	TypesList []string           `json:"types_list" bson:"types_list"`
}
