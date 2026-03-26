package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Violation struct {
	Type        string `json:"type" bson:"type"`
	Date        string `json:"date" bson:"date"`
	Description string `json:"description" bson:"description"`
}

type Message struct {
	Type        string `json:"type" bson:"type"`
	Date        string `json:"date" bson:"date"`
	Description string `json:"description" bson:"description"`
}

type User struct {
	ID         primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Name       string             `json:"name" bson:"name"`
	Number     string             `json:"number" bson:"number"`
	Email      string             `json:"email" bson:"email"`
	Suspend    bool               `json:"suspend" bson:"suspend"`
	Deactivate bool               `json:"deactivate" bson:"deactivate"`
	OTP        string             `json:"otp" bson:"otp"`
	Violations []Violation        `json:"violations" bson:"violations"`
	Messages   []Message          `json:"messages" bson:"messages"`
}
