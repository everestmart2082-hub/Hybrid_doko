package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type ProductUpdateProposed struct {
	Name                 string               `json:"name" bson:"name"`
	Brand                string               `json:"brand" bson:"brand"`
	ShortDescriptions    string               `json:"short_descriptions" bson:"short_descriptions"`
	Description          string               `json:"description" bson:"description"`
	PricePerUnit         float64              `json:"price_per_unit" bson:"price_per_unit"`
	Unit                 string               `json:"unit" bson:"unit"`
	Discount             float64              `json:"discount" bson:"discount"`
	ProductCategory      primitive.ObjectID   `json:"product_category" bson:"product_category"`
	DeliveryCategory     string               `json:"delivery_category" bson:"delivery_category"`
	Stock                int                  `json:"stock" bson:"stock"`
	Photos               []string             `json:"photos" bson:"photos"`
	VendorID             primitive.ObjectID   `json:"vendor_id" bson:"vendor_id"`
	Rating               float64              `json:"rating" bson:"rating"`
	Approved             bool                 `json:"approved" bson:"approved"`
	ReviewIDs            []primitive.ObjectID `json:"review_ids" bson:"review_ids"`
	ReasonForAdminHidden string               `json:"reason_for_admin_hidden" bson:"reason_for_admin_hidden"`
	Hidden               bool                 `json:"hidden" bson:"hidden"`
	AdminHidden          bool                 `json:"admin_hidden" bson:"admin_hidden"`
	SubmittedForDeletion bool                 `json:"submitted_for_deletion" bson:"submitted_for_deletion"`
	SubmittedForUpdate   bool                 `json:"submitted_for_update" bson:"submitted_for_update"`
}

type Product struct {
	ID                   primitive.ObjectID    `json:"id,omitempty" bson:"_id,omitempty"`
	Name                 string                `json:"name" bson:"name"`
	Brand                string                `json:"brand" bson:"brand"`
	ShortDescriptions    string                `json:"short_descriptions" bson:"short_descriptions"`
	Description          string                `json:"description" bson:"description"`
	PricePerUnit         float64               `json:"price_per_unit" bson:"price_per_unit"`
	Unit                 string                `json:"unit" bson:"unit"`
	Discount             float64               `json:"discount" bson:"discount"`
	ProductCategory      primitive.ObjectID    `json:"product_category" bson:"product_category"`
	DeliveryCategory     string                `json:"delivery_category" bson:"delivery_category"`
	Stock                int                   `json:"stock" bson:"stock"`
	Photos               []string              `json:"photos" bson:"photos"`
	VendorID             primitive.ObjectID    `json:"vendor_id" bson:"vendor_id"`
	Rating               float64               `json:"rating" bson:"rating"`
	Approved             bool                  `json:"approved" bson:"approved"`
	ReviewIDs            []primitive.ObjectID  `json:"review_ids" bson:"review_ids"`
	ReasonForAdminHidden string                `json:"reason_for_admin_hidden" bson:"reason_for_admin_hidden"`
	Hidden               bool                  `json:"hidden" bson:"hidden"`
	AdminHidden          bool                  `json:"admin_hidden" bson:"admin_hidden"`
	SubmittedForDeletion bool                  `json:"submitted_for_deletion" bson:"submitted_for_deletion"`
	SubmittedForUpdate   bool                  `json:"submitted_for_update" bson:"submitted_for_update"`
	UpdatesProposed      ProductUpdateProposed `json:"updates_proposed" bson:"updates_proposed"`
}
