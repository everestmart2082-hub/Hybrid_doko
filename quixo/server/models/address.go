package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Address struct {
	ID          primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Label       string             `json:"label" bson:"label"` // Home, work, office
	City        string             `json:"city" bson:"city"`
	State       string             `json:"state" bson:"state"`
	Pincode     string             `json:"pincode" bson:"pincode"`
	Landmark    string             `json:"landmark" bson:"landmark"`
	PhoneNumber string             `json:"phone_number" bson:"phone_number"`
	Email       string             `json:"email" bson:"email"`
	UserID      primitive.ObjectID `json:"user_id" bson:"user_id"`
	Geolocation string             `json:"geolocation" bson:"geolocation"` // {lat,long}
}
