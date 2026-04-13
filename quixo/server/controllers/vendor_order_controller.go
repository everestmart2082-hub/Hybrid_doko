package controllers

import (
	"context"
	"net/http"
	"strings"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// VendorOrderAll handles /api/vender/order/all
func VendorOrderAll(c *gin.Context) {
	vendorID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	status := strings.TrimSpace(c.PostForm("status"))
	deliveryCategory := strings.ToLower(strings.TrimSpace(c.PostForm("delivary category")))
	searchText := strings.ToLower(strings.TrimSpace(c.PostForm("search text")))

	itemColl := utils.GetCollection("order")
	parentColl := utils.GetCollection("orders")
	productColl := utils.GetCollection("products")
	riderColl := utils.GetCollection("riders")
	userColl := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	productCursor, _ := productColl.Find(ctx, bson.M{"vendor_id": vendorID})
	var products []bson.M
	productCursor.All(ctx, &products)
	productMap := map[primitive.ObjectID]bson.M{}
	var productIDs []primitive.ObjectID
	for _, p := range products {
		if pid, ok := p["_id"].(primitive.ObjectID); ok {
			productIDs = append(productIDs, pid)
			productMap[pid] = p
		}
	}
	if len(productIDs) == 0 {
		c.JSON(http.StatusOK, gin.H{"success": true, "message": []interface{}{"orders id", []gin.H{}}})
		return
	}

	filter := bson.M{"product_id": bson.M{"$in": productIDs}}
	if status != "" {
		filter["status"] = strings.ToLower(status)
	}
	if deliveryCategory != "" {
		filter["type"] = deliveryCategory
	}
	cursor, _ := itemColl.Find(ctx, filter, options.Find().SetSort(bson.M{"date_of_order": -1}).SetLimit(200))
	var items []bson.M
	cursor.All(ctx, &items)

	var mapped []gin.H
	for _, o := range items {
		pid, _ := o["product_id"].(primitive.ObjectID)
		product := productMap[pid]
		productName, _ := product["name"].(string)
		if searchText != "" && !strings.Contains(strings.ToLower(productName), searchText) {
			continue
		}
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
			"product name":      productName,
			"product category":  product["product_category"],
			"delivary category": o["type"],
			"order time":        o["date_of_order"],
			"product id":        o["product_id"],
			"product number":    o["number"],
			"rider name":        riderName,
			"rider number":      riderNumber,
			"rider id":          riderIDHex,
			"user name":         userName,
			"user number":       userNumber,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": []interface{}{"orders id", mapped},
	})
}

// VendorAssignRider handles /api/vender/order/assign-rider
func VendorAssignRider(c *gin.Context) {
	vendorIDVal, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}
	targetID := c.PostForm("orders id")
	if targetID == "" {
		targetID = c.PostForm("order id")
	}
	riderIDStr := c.PostForm("rider id")
	riderID, err := primitive.ObjectIDFromHex(riderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid rider id"})
		return
	}
	targetOID, err := primitive.ObjectIDFromHex(targetID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid order id"})
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
		_, err = coll.UpdateOne(
			ctx,
			bson.M{"_id": targetOID, "status": "preparing"},
			bson.M{"$set": bson.M{"rider_id": riderID}},
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
			return
		}
	}
	if vid, ok := vendorIDVal.(primitive.ObjectID); ok {
		emitOrderEvent(ctx, eventRiderAssigned, targetOID, "vendor", vid, "assigned")
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "rider assigned"})
}

// VendorOrderPrepared handles /api/vender/order/prepared/
func VendorOrderPrepared(c *gin.Context) {
	vendorIDVal, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	orderIDStr := c.PostForm("order id")
	if orderIDStr == "" {
		orderIDStr = c.PostForm("orders id")
	}
	orderID, err := primitive.ObjectIDFromHex(orderIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "server error"})
		return
	}

	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	res, err := coll.UpdateMany(
		ctx,
		bson.M{"orders_id": orderID, "status": "preparing", "rider_id": bson.M{"$exists": true, "$ne": nil}},
		bson.M{"$set": bson.M{"status": "pending"}},
	)
	if err == nil && res.MatchedCount == 0 {
		resOne, errOne := coll.UpdateOne(
			ctx,
			bson.M{"_id": orderID, "status": "preparing", "rider_id": bson.M{"$exists": true, "$ne": nil}},
			bson.M{"$set": bson.M{"status": "pending"}},
		)
		if errOne != nil || resOne.MatchedCount == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "assign rider before preparing"})
			return
		}
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	if vid, ok := vendorIDVal.(primitive.ObjectID); ok {
		emitOrderEvent(ctx, eventOrderPrepared, orderID, "vendor", vid, "pending")
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order prepared"})
}
