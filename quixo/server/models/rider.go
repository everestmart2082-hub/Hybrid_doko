package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type RiderUpdateProposed struct {
	Name         string `json:"name" bson:"name"`
	Address      string `json:"address" bson:"address"`
	Email        string `json:"email" bson:"email"`
	Description  string `json:"description" bson:"description"`
	Geolocation  string `json:"geolocation" bson:"geolocation"`
}

type Rider struct {
	ID                    primitive.ObjectID  `json:"id,omitempty" bson:"_id,omitempty"`
	Name                  string              `json:"name" bson:"name"`
	Number                string              `json:"number" bson:"number"`
	Email                 string              `json:"email" bson:"email"`
	Rating                float64             `json:"rating" bson:"rating"`
	RcBookFile            string              `json:"rc_book_file" bson:"rc_book_file"`
	CitizenshipFile       string              `json:"citizenship_file" bson:"citizenship_file"`
	PanCardFile           string              `json:"pan_card_file" bson:"pan_card_file"`
	Address               string              `json:"address" bson:"address"`
	BikeModel             string              `json:"bike_model" bson:"bike_model"`
	BikeNumber            string              `json:"bike_number" bson:"bike_number"`
	BikeColor             string              `json:"bike_color" bson:"bike_color"`
	Type                  string              `json:"type" bson:"type"` // bike or scooter
	BikeInsuranceFile     string              `json:"bike_insurance_paper_file" bson:"bike_insurance_paper_file"`
	Verified              bool                `json:"verified" bson:"verified"`
	UpdationRequested     bool                `json:"updation_requested" bson:"updation_requested"`
	Suspended             bool                `json:"suspended" bson:"suspended"`
	Revenue               float64             `json:"revenue" bson:"revenue"`
	Violations            []Violation         `json:"violations" bson:"violations"`
	OTP                   string              `json:"otp" bson:"otp"`
	UpdatesProposed       RiderUpdateProposed `json:"updates_proposed" bson:"updates_proposed"`
	Messages              []Message           `json:"messages" bson:"messages"`
	// Message is cumulative text from admin notify (and similar); appended on each send.
	Message string `json:"message" bson:"message"`
}
