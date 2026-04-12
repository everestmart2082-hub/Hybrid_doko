package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type VendorUpdateProposed struct {
	Name         string `json:"name" bson:"name"`
	Address      string `json:"address" bson:"address"`
	Email        string `json:"email" bson:"email"`
	Description  string `json:"description" bson:"description"`
	Geolocation  string `json:"geolocation" bson:"geolocation"`
}

type Vendor struct {
	ID                primitive.ObjectID   `json:"id,omitempty" bson:"_id,omitempty"`
	Name              string               `json:"name" bson:"name"`
	Number            string               `json:"number" bson:"number"`
	PanFile           string               `json:"pan_file" bson:"pan_file"`
	StoreName         string               `json:"store_name" bson:"store_name"`
	Address           string               `json:"address" bson:"address"`
	Email             string               `json:"email" bson:"email"`
	BusinessType      string               `json:"business_type" bson:"business_type"`
	Description       string               `json:"description" bson:"description"`
	Verified          bool                 `json:"verified" bson:"verified"`
	Suspended         bool                 `json:"suspended" bson:"suspended"`
	Revenue           float64              `json:"revenue" bson:"revenue"`
	Geolocation       string               `json:"geolocation" bson:"geolocation"`
	Violations        []Violation          `json:"violations" bson:"violations"`
	OTP               string               `json:"otp" bson:"otp"`
	UpdationRequested bool                 `json:"updation_requested" bson:"updation_requested"`
	UpdatesProposed   VendorUpdateProposed `json:"updates_proposed" bson:"updates_proposed"`
	Messages          []Message            `json:"messages" bson:"messages"`
	// Message is cumulative text from admin notify (and similar); appended on each send.
	Message string `json:"message" bson:"message"`
}
