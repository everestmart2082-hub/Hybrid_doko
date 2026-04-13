package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// AdminChangeConstants handles /api/admin/changeConstants
func AdminChangeConstants(c *gin.Context) {
	name := c.PostForm("name")
	typesList := c.PostFormArray("type list []")
	if len(typesList) == 0 {
		standalone := c.PostForm("type list")
		if standalone != "" {
			typesList = append(typesList, standalone)
		}
	}
	action := c.PostForm("doingwhat")

	coll := utils.GetCollection("constants")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var update bson.M
	if action == "add" {
		update = bson.M{"$push": bson.M{"types_list": bson.M{"$each": typesList}}}
	} else if action == "remove" {
		update = bson.M{"$pullAll": bson.M{"types_list": typesList}}
	} else {
		update = bson.M{"$set": bson.M{"types_list": typesList}}
	}

	opts := options.Update().SetUpsert(true)
	_, err := coll.UpdateOne(ctx, bson.M{"name": name}, update, opts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "failure"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}

// AdminGetAllConstants handles /api/admin/constants/all — list all constant documents (e.g. Business type).
func AdminGetAllConstants(c *gin.Context) {
	coll := utils.GetCollection("constants")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	cursor, err := coll.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "failure"})
		return
	}
	defer cursor.Close(ctx)
	var list []models.Constant
	if err := cursor.All(ctx, &list); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "failure"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": list})
}

// AdminDeleteConstant handles /api/admin/constants/delete
func AdminDeleteConstant(c *gin.Context) {
	name := c.PostForm("name")
	if name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "failure"})
		return
	}
	coll := utils.GetCollection("constants")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if _, err := coll.DeleteOne(ctx, bson.M{"name": name}); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "failure"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}

// AdminOrderAll handles /api/admin/order/all
func AdminOrderAll(c *gin.Context) {
	itemColl := utils.GetCollection("order")
	parentColl := utils.GetCollection("orders")
	productColl := utils.GetCollection("products")
	vendorColl := utils.GetCollection("vendors")
	riderColl := utils.GetCollection("riders")
	userColl := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := itemColl.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"date_of_order": -1}).SetLimit(200))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, o := range results {
		productID, _ := o["product_id"].(primitive.ObjectID)
		var product bson.M
		_ = productColl.FindOne(ctx, bson.M{"_id": productID}).Decode(&product)
		vendorID, _ := product["vendor_id"].(primitive.ObjectID)
		var vendor bson.M
		_ = vendorColl.FindOne(ctx, bson.M{"_id": vendorID}).Decode(&vendor)
		riderName := ""
		riderNumber := ""
		riderIDHex := ""
		if riderID, ok := o["rider_id"].(primitive.ObjectID); ok && !riderID.IsZero() {
			riderIDHex = riderID.Hex()
			var rider bson.M
			if err := riderColl.FindOne(ctx, bson.M{"_id": riderID}).Decode(&rider); err == nil {
				riderName, _ = rider["name"].(string)
				riderNumber, _ = rider["number"].(string)
			}
		}
		userName := ""
		userNumber := ""
		if ordersID, ok := o["orders_id"].(primitive.ObjectID); ok {
			var parent bson.M
			if err := parentColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&parent); err == nil {
				if uid, ok := parent["user_id"].(primitive.ObjectID); ok {
					var user bson.M
					if err := userColl.FindOne(ctx, bson.M{"_id": uid}).Decode(&user); err == nil {
						userName, _ = user["name"].(string)
						userNumber, _ = user["number"].(string)
					}
				}
			}
		}
		mapped = append(mapped, gin.H{
			"order id":          o["_id"],
			"orders id":         o["orders_id"],
			"order status":      o["status"],
			"product category":  product["product_category"],
			"delivary category": o["type"],
			"order time":        o["date_of_order"],
			"product id":        o["product_id"],
			"product number":    o["number"],
			"vender id":         vendorID,
			"vendor name":       vendor["name"],
			"rider id":          riderIDHex,
			"rider name":        riderName,
			"rider number":      riderNumber,
			"user name":         userName,
			"user number":       userNumber,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": mapped,
	})
}

// AdminAssignRider handles /api/admin/order/assign-rider
func AdminAssignRider(c *gin.Context) {
	adminIDVal, _ := c.Get("userID")
	targetID := c.PostForm("orders id")
	if targetID == "" {
		targetID = c.PostForm("order id")
	}
	riderIDStr := c.PostForm("rider id")
	targetOID, err := primitive.ObjectIDFromHex(targetID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid order id"})
		return
	}
	riderID, err := primitive.ObjectIDFromHex(riderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid rider id"})
		return
	}
	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	res, err := coll.UpdateMany(
		ctx,
		bson.M{"orders_id": targetOID, "status": "preparing"},
		bson.M{"$set": bson.M{"rider_id": riderID}},
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	if res.MatchedCount == 0 {
		_, err = coll.UpdateOne(ctx, bson.M{"_id": targetOID, "status": "preparing"}, bson.M{"$set": bson.M{"rider_id": riderID}})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
	}
	if aid, ok := adminIDVal.(primitive.ObjectID); ok {
		emitOrderEvent(ctx, eventRiderAssigned, targetOID, "admin", aid, "assigned")
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "rider assigned"})
}

// AdminDashboard handles /api/admin/dashboard
func AdminDashboard(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	orderColl := utils.GetCollection("order")
	productColl := utils.GetCollection("products")
	vendorColl := utils.GetCollection("vendors")
	riderColl := utils.GetCollection("riders")
	customerColl := utils.GetCollection("users")

	count := func(collName string, filter bson.M) int64 {
		n, _ := utils.GetCollection(collName).CountDocuments(ctx, filter)
		return n
	}

	preparing := count("order", bson.M{"status": "preparing"})
	pending := count("order", bson.M{"status": "pending"})
	delivered := count("order", bson.M{"status": "delivered"})
	cancelled := count("order", bson.M{"status": bson.M{"$in": bson.A{"cancelledByUser", "cancelledByVender"}}})

	revenueCursor, _ := orderColl.Find(ctx, bson.M{"status": "delivered"})
	var deliveredOrders []bson.M
	revenueCursor.All(ctx, &deliveredOrders)
	totalRevenue := 0.0
	for _, it := range deliveredOrders {
		if v, ok := it["line_total"].(float64); ok {
			totalRevenue += v
		}
	}

	approvedProducts := count("products", bson.M{"approved": true, "hidden": bson.M{"$ne": true}})
	hiddenProducts := count("products", bson.M{"hidden": true})
	verifiedVendors := count("vendors", bson.M{"verified": true, "suspended": bson.M{"$ne": true}})
	suspendedVendors := count("vendors", bson.M{"suspended": true})
	verifiedRiders := count("riders", bson.M{"verified": true, "suspended": bson.M{"$ne": true}})
	suspendedRiders := count("riders", bson.M{"suspended": true})
	totalCustomers := count("users", bson.M{})

	_ = productColl
	_ = vendorColl
	_ = riderColl
	_ = customerColl

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": gin.H{
			"total_revenue":     totalRevenue,
			"orders_preparing":  preparing,
			"orders_pending":    pending,
			"orders_delivered":  delivered,
			"orders_cancelled":  cancelled,
			"products_approved": approvedProducts,
			"products_hidden":   hiddenProducts,
			"vendors_verified":  verifiedVendors,
			"vendors_suspended": suspendedVendors,
			"riders_verified":   verifiedRiders,
			"riders_suspended":  suspendedRiders,
			"customers_total":   totalCustomers,
		},
	})
}

// AdminGetAllEmployees handles /api/admin/employee/all
// Returns a slimmed-down list of employees with basic info + violations.
func AdminGetAllEmployees(c *gin.Context) {
	coll := utils.GetCollection("employees")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{}, options.Find().SetLimit(200))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, v := range results {
		mapped = append(mapped, gin.H{
			"id":               v["_id"],
			"name":             v["name"],
			"email":            v["email"],
			"phone":            v["phone"],
			"position":         v["position"],
			"salary":           v["salary"],
			"address":          v["address"],
			"citizenship_file": v["citizenship_file"],
			"bank_name":        v["bank name"],
			"account_number":   v["account_number"],
			"pan_file":         v["pan_file"],
			"suspended":        v["suspended"],
			"violations":       v["violations"],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": mapped,
	})
}
