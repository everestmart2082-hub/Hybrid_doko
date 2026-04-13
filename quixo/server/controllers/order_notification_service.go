package controllers

import (
	"context"
	"fmt"
	"strings"
	"time"

	"quixo-server/utils"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

const (
	eventOrderCreated                 = "order_created"
	eventRiderAssigned                = "rider_assigned"
	eventRiderAccepted                = "rider_accepted"
	eventOrderPrepared                = "order_prepared"
	eventOrderStatusChanged           = "order_status_changed"
	eventOrderDelivered               = "order_delivered"
	eventCustomerRegistered           = "customer_registered"
	eventVendorRegistered             = "vendor_registered"
	eventRiderRegistered              = "rider_registered"
	eventCustomerProfileUpdateRequest = "customer_profile_update_requested"
	eventVendorProfileUpdateRequest   = "vendor_profile_update_requested"
	eventRiderProfileUpdateRequest    = "rider_profile_update_requested"
	eventVendorProductAdded           = "vendor_product_added"
	eventVendorProductEditRequested   = "vendor_product_edit_requested"
)

func recordLifecycleEvent(ctx context.Context, eventType string, orderID primitive.ObjectID, status string, actorRole string, actorID primitive.ObjectID, targetIDs []primitive.ObjectID, payload map[string]string) error {
	coll := utils.GetCollection("events")
	doc := bson.M{
		"_id":        primitive.NewObjectID(),
		"type":       eventType,
		"order_id":   orderID,
		"status":     status,
		"actor_role": actorRole,
		"actor_id":   actorID,
		"target_ids": targetIDs,
		"payload":    payload,
		"created_at": time.Now(),
	}
	_, err := coll.InsertOne(ctx, doc)
	return err
}

func insertRoleNotification(ctx context.Context, roleType string, targetID primitive.ObjectID, message string, category string) error {
	if targetID.IsZero() || strings.TrimSpace(roleType) == "" || strings.TrimSpace(message) == "" {
		return nil
	}
	ncoll := utils.GetCollection("notifications")
	_, err := ncoll.InsertOne(ctx, bson.M{
		"_id":       primitive.NewObjectID(),
		"type":      roleType,
		"message":   message,
		"target_id": targetID,
		"date":      time.Now(),
		"received":  false,
		"category":  category,
	})
	return err
}

func shortOrderID(id primitive.ObjectID) string {
	hex := id.Hex()
	if len(hex) < 6 {
		return hex
	}
	return strings.ToUpper(hex[len(hex)-6:])
}

func appendUniqueIDs(base []primitive.ObjectID, ids ...primitive.ObjectID) []primitive.ObjectID {
	seen := map[string]bool{}
	for _, id := range base {
		if !id.IsZero() {
			seen[id.Hex()] = true
		}
	}
	for _, id := range ids {
		if id.IsZero() {
			continue
		}
		if seen[id.Hex()] {
			continue
		}
		seen[id.Hex()] = true
		base = append(base, id)
	}
	return base
}

func emitRegistrationEvent(ctx context.Context, roleType string, targetID primitive.ObjectID, includeAdmin bool) {
	if targetID.IsZero() {
		return
	}
	eventType := eventCustomerRegistered
	switch roleType {
	case "vendor":
		eventType = eventVendorRegistered
	case "rider":
		eventType = eventRiderRegistered
	}
	msg := "Registration completed successfully."
	_ = insertRoleNotification(ctx, roleType, targetID, msg, "register")
	if includeAdmin {
		_ = pushContactToAllAdmins(ctx, "register", "", "", fmt.Sprintf("[%s] %s", roleType, msg), fmt.Sprintf("Target ID: %s", targetID.Hex()), "register")
	}
	_ = recordLifecycleEvent(ctx, eventType, primitive.NilObjectID, "completed", roleType, targetID, []primitive.ObjectID{targetID}, map[string]string{"category": "register"})
}

func emitProfileUpdateRequestedEvent(ctx context.Context, roleType string, targetID primitive.ObjectID, includeAdmin bool) {
	if targetID.IsZero() {
		return
	}
	eventType := eventCustomerProfileUpdateRequest
	switch roleType {
	case "vendor":
		eventType = eventVendorProfileUpdateRequest
	case "rider":
		eventType = eventRiderProfileUpdateRequest
	}
	msg := "Your profile update request has been submitted for review."
	_ = insertRoleNotification(ctx, roleType, targetID, msg, "profile")
	if includeAdmin {
		_ = pushContactToAllAdmins(ctx, "profile", "", "", fmt.Sprintf("[%s] Profile update requested.", roleType), fmt.Sprintf("Target ID: %s", targetID.Hex()), "profile")
	}
	_ = recordLifecycleEvent(ctx, eventType, primitive.NilObjectID, "requested", roleType, targetID, []primitive.ObjectID{targetID}, map[string]string{"category": "profile"})
}

func emitVendorProductEvent(ctx context.Context, eventType string, vendorID primitive.ObjectID, productID primitive.ObjectID, productName string, includeAdmin bool) {
	if vendorID.IsZero() {
		return
	}
	if strings.TrimSpace(productName) == "" {
		productName = "Product"
	}
	msg := fmt.Sprintf("%s submitted for verification.", productName)
	if eventType == eventVendorProductEditRequested {
		msg = fmt.Sprintf("%s submitted for update review.", productName)
	}
	_ = insertRoleNotification(ctx, "vendor", vendorID, msg, "product")
	if includeAdmin {
		_ = pushContactToAllAdmins(ctx, "product", "", "", msg, fmt.Sprintf("Vendor ID: %s | Product ID: %s", vendorID.Hex(), productID.Hex()), "product")
	}
	payload := map[string]string{"product_name": productName, "product_id": productID.Hex(), "category": "product"}
	_ = recordLifecycleEvent(ctx, eventType, primitive.NilObjectID, "submitted", "vendor", vendorID, []primitive.ObjectID{vendorID}, payload)
}

func toObjectID(value interface{}) primitive.ObjectID {
	if oid, ok := value.(primitive.ObjectID); ok && !oid.IsZero() {
		return oid
	}
	return primitive.NilObjectID
}

func collectOrderParticipants(ctx context.Context, ordersID primitive.ObjectID) (primitive.ObjectID, primitive.ObjectID, []primitive.ObjectID) {
	var customerID primitive.ObjectID
	var riderID primitive.ObjectID
	vendorIDs := []primitive.ObjectID{}
	if ordersID.IsZero() {
		return customerID, riderID, vendorIDs
	}

	parentColl := utils.GetCollection("orders")
	var parent bson.M
	if err := parentColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&parent); err == nil {
		customerID = toObjectID(parent["user_id"])
	}

	itemColl := utils.GetCollection("order")
	cursor, err := itemColl.Find(ctx, bson.M{"orders_id": ordersID})
	if err != nil {
		return customerID, riderID, vendorIDs
	}
	var items []bson.M
	_ = cursor.All(ctx, &items)
	if len(items) == 0 {
		var one bson.M
		if err := itemColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&one); err == nil {
			items = []bson.M{one}
		}
	}

	productColl := utils.GetCollection("products")
	for _, item := range items {
		if riderID.IsZero() {
			riderID = toObjectID(item["rider_id"])
		}
		pid := toObjectID(item["product_id"])
		if pid.IsZero() {
			continue
		}
		var product bson.M
		if err := productColl.FindOne(ctx, bson.M{"_id": pid}).Decode(&product); err == nil {
			vid := toObjectID(product["vendor_id"])
			vendorIDs = appendUniqueIDs(vendorIDs, vid)
		}
	}
	return customerID, riderID, vendorIDs
}

func emitOrderEvent(ctx context.Context, eventType string, ordersID primitive.ObjectID, actorRole string, actorID primitive.ObjectID, status string) {
	if ordersID.IsZero() {
		return
	}
	customerID, riderID, vendorIDs := collectOrderParticipants(ctx, ordersID)
	shortID := shortOrderID(ordersID)

	customerMsg := fmt.Sprintf("Your order #%s status changed.", shortID)
	vendorMsg := fmt.Sprintf("Order #%s status updated.", shortID)
	riderMsg := fmt.Sprintf("Order #%s updated.", shortID)
	switch eventType {
	case eventOrderCreated:
		customerMsg = fmt.Sprintf("Your order #%s has been placed.", shortID)
		vendorMsg = fmt.Sprintf("New order #%s placed by a customer.", shortID)
	case eventRiderAssigned:
		customerMsg = fmt.Sprintf("A rider has been assigned to your order #%s.", shortID)
		vendorMsg = fmt.Sprintf("Rider assigned to order #%s.", shortID)
		riderMsg = fmt.Sprintf("You have been assigned order #%s.", shortID)
	case eventRiderAccepted:
		customerMsg = fmt.Sprintf("A rider accepted your order #%s.", shortID)
		vendorMsg = fmt.Sprintf("Rider accepted order #%s.", shortID)
		riderMsg = fmt.Sprintf("You accepted order #%s.", shortID)
	case eventOrderPrepared:
		customerMsg = fmt.Sprintf("Your order #%s is prepared and awaiting delivery.", shortID)
		vendorMsg = fmt.Sprintf("Order #%s marked prepared.", shortID)
		riderMsg = fmt.Sprintf("Order #%s is prepared for pickup.", shortID)
	case eventOrderDelivered:
		customerMsg = fmt.Sprintf("Your order #%s was delivered successfully.", shortID)
		vendorMsg = fmt.Sprintf("Order #%s was delivered.", shortID)
		riderMsg = fmt.Sprintf("Order #%s marked delivered.", shortID)
	}

	_ = insertRoleNotification(ctx, "user", customerID, customerMsg, "order_lifecycle")
	for _, vid := range vendorIDs {
		_ = insertRoleNotification(ctx, "vendor", vid, vendorMsg, "order_lifecycle")
	}
	if !riderID.IsZero() {
		_ = insertRoleNotification(ctx, "rider", riderID, riderMsg, "order_lifecycle")
	}

	adminBody := fmt.Sprintf("Order #%s event: %s", shortID, eventType)
	adminFooter := fmt.Sprintf("orders_id: %s | actor: %s(%s)", ordersID.Hex(), actorRole, actorID.Hex())
	_ = pushContactToAllAdmins(ctx, "order", "", "", adminBody, adminFooter, "order")

	targets := appendUniqueIDs([]primitive.ObjectID{}, customerID, riderID, actorID)
	targets = appendUniqueIDs(targets, vendorIDs...)
	_ = recordLifecycleEvent(ctx, eventType, ordersID, status, actorRole, actorID, targets, map[string]string{"category": "order_lifecycle"})
}
