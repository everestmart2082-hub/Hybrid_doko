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

// RiderOrderAll handles /api/rider/order/all
func RiderOrderAll(c *gin.Context) {
	riderID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	status := strings.ToLower(strings.TrimSpace(c.PostForm("status")))
	deliveryCategory := strings.ToLower(strings.TrimSpace(c.PostForm("delivary category")))
	searchText := strings.ToLower(strings.TrimSpace(c.PostForm("search text")))

	filter := bson.M{}
	if status != "" {
		filter["status"] = status
	}
	if deliveryCategory != "" {
		filter["type"] = deliveryCategory
	}
	if status == "preparing" {
		filter["$or"] = bson.A{
			bson.M{"rider_id": riderID},
			bson.M{"rider_id": bson.M{"$exists": false}},
			bson.M{"rider_id": nil},
			bson.M{"rider_id": primitive.NilObjectID},
		}
	} else {
		filter["rider_id"] = riderID
	}

	coll := utils.GetCollection("order")
	productColl := utils.GetCollection("products")
	vendorColl := utils.GetCollection("vendors")
	parentColl := utils.GetCollection("orders")
	userColl := utils.GetCollection("users")
	addressColl := utils.GetCollection("addresses")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := coll.Find(ctx, filter, options.Find().SetLimit(50))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, o := range results {
		productID, _ := o["product_id"].(primitive.ObjectID)
		var product bson.M
		_ = productColl.FindOne(ctx, bson.M{"_id": productID}).Decode(&product)
		productName, _ := product["name"].(string)
		if searchText != "" && !strings.Contains(strings.ToLower(productName), searchText) {
			continue
		}
		vendorName := ""
		vendorAddress := ""
		if vendorID, ok := product["vendor_id"].(primitive.ObjectID); ok {
			var vendor bson.M
			if err := vendorColl.FindOne(ctx, bson.M{"_id": vendorID}).Decode(&vendor); err == nil {
				vendorName, _ = vendor["name"].(string)
				vendorAddress, _ = vendor["address"].(string)
			}
		}
		userName := ""
		userNumber := ""
		userAddress := ""
		if ordersID, ok := o["orders_id"].(primitive.ObjectID); ok {
			var parent bson.M
			if err := parentColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&parent); err == nil {
				if uid, ok := parent["user_id"].(primitive.ObjectID); ok {
					var user bson.M
					if err := userColl.FindOne(ctx, bson.M{"_id": uid}).Decode(&user); err == nil {
						userName, _ = user["name"].(string)
						userNumber, _ = user["number"].(string)
					}
					addressFilter := bson.M{"user_id": uid}
					if addrID, ok := parent["address_id"].(primitive.ObjectID); ok && !addrID.IsZero() {
						addressFilter = bson.M{"_id": addrID}
					}
					var addr bson.M
					if err := addressColl.FindOne(ctx, addressFilter).Decode(&addr); err == nil {
						if lm, ok := addr["landmark"].(string); ok {
							userAddress = lm
						}
						if userAddress == "" {
							if city, ok := addr["city"].(string); ok {
								userAddress = city
							}
						}
					}
				}
			}
		}
		accepted := false
		if assigned, ok := o["rider_id"].(primitive.ObjectID); ok && assigned == riderID {
			accepted = true
		}
		mapped = append(mapped, gin.H{
			"order id":          o["_id"],
			"orders id":         o["orders_id"],
			"order status":      o["status"],
			"product name":      product["name"],
			"product category":  product["product_category"],
			"vendor name":       vendorName,
			"vendor address":    vendorAddress,
			"user name":         userName,
			"user number":       userNumber,
			"user address":      userAddress,
			"delivary category": o["type"],
			"order time":        o["date_of_order"],
			"product id":        o["product_id"],
			"product number":    o["number"],
			"accepted":          accepted,
		})
	}

	// Schema states nested orders in array wrapper format based directly on allOrder.txt
	wrapper := []interface{}{"orders id", mapped}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": wrapper})
}

// RiderGenerateOTP handles /api/rider/generate_otp
func RiderGenerateOTP(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	orderColl := utils.GetCollection("order")
	ordersColl := utils.GetCollection("orders")
	userColl := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var orderDoc bson.M
	err := orderColl.FindOne(ctx, bson.M{"orders_id": orderID}).Decode(&orderDoc)
	if err != nil {
		err = orderColl.FindOne(ctx, bson.M{"_id": orderID}).Decode(&orderDoc)
	}
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "order not found"})
		return
	}

	ordersID, _ := orderDoc["orders_id"].(primitive.ObjectID)
	if ordersID.IsZero() {
		ordersID = orderID
	}
	var parent bson.M
	if err := ordersColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&parent); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "parent order not found"})
		return
	}
	userID, ok := parent["user_id"].(primitive.ObjectID)
	if !ok || userID.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "user not found"})
		return
	}

	otp, _ := GenerateOTP()
	_, err = userColl.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": bson.M{"otp": otp}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	// OTP generated to match user on drop-off.
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully generated otp"})
}

// RiderDeliverProduct handles /api/rider/order/delivered
func RiderDeliverProduct(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)
	otp := c.PostForm("otp")

	orderColl := utils.GetCollection("order")
	ordersColl := utils.GetCollection("orders")
	userColl := utils.GetCollection("users")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var orderDoc bson.M
	err := orderColl.FindOne(ctx, bson.M{"orders_id": orderID}).Decode(&orderDoc)
	if err != nil {
		err = orderColl.FindOne(ctx, bson.M{"_id": orderID}).Decode(&orderDoc)
	}
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "order not found"})
		return
	}

	ordersID, _ := orderDoc["orders_id"].(primitive.ObjectID)
	if ordersID.IsZero() {
		ordersID = orderID
	}
	var parent bson.M
	if err := ordersColl.FindOne(ctx, bson.M{"_id": ordersID}).Decode(&parent); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "parent order not found"})
		return
	}
	userID, ok := parent["user_id"].(primitive.ObjectID)
	if !ok || userID.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "user not found"})
		return
	}

	var user bson.M
	if err := userColl.FindOne(ctx, bson.M{"_id": userID, "otp": otp}).Decode(&user); err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	// Decrease product stock for line items that are not already delivered (idempotent on repeat calls).
	productColl := utils.GetCollection("products")
	lineFilter := bson.M{
		"orders_id": ordersID,
		"status":    bson.M{"$ne": "delivered"},
	}
	curLines, err := orderColl.Find(ctx, lineFilter)
	if err == nil {
		var pending []bson.M
		_ = curLines.All(ctx, &pending)
		if len(pending) == 0 {
			var one bson.M
			if err2 := orderColl.FindOne(ctx, bson.M{"_id": orderID, "status": bson.M{"$ne": "delivered"}}).Decode(&one); err2 == nil {
				pending = []bson.M{one}
			}
		}
		for _, line := range pending {
			pid, ok := line["product_id"].(primitive.ObjectID)
			if !ok || pid.IsZero() {
				continue
			}
			qty := 1
			switch n := line["number"].(type) {
			case int32:
				qty = int(n)
			case int64:
				qty = int(n)
			case int:
				qty = n
			case float64:
				qty = int(n)
			}
			if qty <= 0 {
				continue
			}
			_, _ = productColl.UpdateOne(ctx, bson.M{"_id": pid}, bson.M{"$inc": bson.M{"stock": -qty}})
		}
	}

	res, _ := orderColl.UpdateMany(ctx, bson.M{"orders_id": ordersID}, bson.M{"$set": bson.M{"status": "delivered"}})
	if res.MatchedCount == 0 {
		orderColl.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "delivered"}})
	}
	_, _ = userColl.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$unset": bson.M{"otp": ""}})
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order delvered"}) // mimicking exact schema text
}

// RiderRejectOrder handles /api/rider/order/reject
func RiderRejectOrder(c *gin.Context) {
	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	res, err := coll.UpdateMany(ctx, bson.M{"orders_id": orderID, "rider_id": bson.M{"$exists": true}}, bson.M{"$set": bson.M{"status": "returned", "rider_id": nil}})
	if err == nil && res.MatchedCount == 0 {
		_, err = coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "returned", "rider_id": nil}})
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order rejected"})
}

// RiderAcceptOrder handles /api/rider/order/accept
func RiderAcceptOrder(c *gin.Context) {
	riderID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	orderIDStr := c.PostForm("orders id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Accept by parent orders id first; fallback to single item.
	res, err := coll.UpdateMany(
		ctx,
		bson.M{
			"orders_id": orderID,
			// "status":    "preparing",
			"$or": bson.A{
				bson.M{"rider_id": riderID},
				bson.M{"rider_id": nil},
				bson.M{"rider_id": primitive.NilObjectID},
				bson.M{"rider_id": bson.M{"$exists": false}},
			},
		},
		bson.M{"$set": bson.M{"rider_id": riderID}},
	)
	if err == nil && res.MatchedCount == 0 {
		_, err = coll.UpdateOne(
			ctx,
			bson.M{
				"_id": orderID,
				"$or": bson.A{
					bson.M{"rider_id": riderID},
					bson.M{"rider_id": nil},
					bson.M{"rider_id": primitive.NilObjectID},
					bson.M{"rider_id": bson.M{"$exists": false}},
				},
			},
			bson.M{"$set": bson.M{"rider_id": riderID}},
		)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "order accepted"})
}
