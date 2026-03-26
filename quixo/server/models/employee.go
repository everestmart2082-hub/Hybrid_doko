package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Employee struct {
	ID               primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
	Position         string             `json:"position" bson:"position"`
	Salary           float64            `json:"salary" bson:"salary"`
	Name             string             `json:"name" bson:"name"`
	Address          string             `json:"address" bson:"address"`
	Email            string             `json:"email" bson:"email"`
	Phone            string             `json:"phone" bson:"phone"`
	CitizenshipFile  string             `json:"citizenship_file" bson:"citizenship_file"`
	BankName         string             `json:"bank_name" bson:"bank_name"`
	AccountNumber    string             `json:"account_number" bson:"account_number"`
	PanFile          string             `json:"pan_file" bson:"pan_file"`
	Suspended        bool               `json:"suspended" bson:"suspended"`
	Violations       []Violation        `json:"violations" bson:"violations"`
}
