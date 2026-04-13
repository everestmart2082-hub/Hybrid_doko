package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Event struct {
	ID               primitive.ObjectID   `json:"id,omitempty" bson:"_id,omitempty"`
	Type             string               `json:"type" bson:"type"` // order preparing, cancelledbycustomer, cancelledbyvendor, etc.
	OrderID          primitive.ObjectID   `json:"order_id" bson:"order_id"`
	Status           string               `json:"status" bson:"status"` // running / completed
	CompletedEventID primitive.ObjectID   `json:"completed_event_id,omitempty" bson:"completed_event_id,omitempty"`
	ActorRole        string               `json:"actor_role,omitempty" bson:"actor_role,omitempty"`
	ActorID          primitive.ObjectID   `json:"actor_id,omitempty" bson:"actor_id,omitempty"`
	TargetIDs        []primitive.ObjectID `json:"target_ids,omitempty" bson:"target_ids,omitempty"`
	Payload          map[string]string    `json:"payload,omitempty" bson:"payload,omitempty"`
}
