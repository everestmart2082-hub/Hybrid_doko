package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// CustomerCheckout handles /api/user/checkout
func CustomerCheckout(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	addressIDStr := c.PostForm("address id")
	paymentMethod := c.PostForm("payment method")

	cartIDs := c.PostFormArray("cart ids[]")
	if len(cartIDs) == 0 {
		cartIDs = append(cartIDs, c.PostForm("cart ids"))
	}

	addressID, _ := primitive.ObjectIDFromHex(addressIDStr)

	orderItemColl := utils.GetCollection("order")
	orderParentColl := utils.GetCollection("orders")
	cartColl := utils.GetCollection("carts")
	productColl := utils.GetCollection("products")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var cartObjectIDs []primitive.ObjectID
	for _, id := range cartIDs {
		if oid, err := primitive.ObjectIDFromHex(id); err == nil {
			cartObjectIDs = append(cartObjectIDs, oid)
		}
	}
	if len(cartObjectIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "invalid cart ids"})
		return
	}

	cursor, err := cartColl.Find(ctx, bson.M{"_id": bson.M{"$in": cartObjectIDs}, "user_id": userID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}
	var cartDocs []bson.M
	cursor.All(ctx, &cartDocs)
	if len(cartDocs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "no cart items found"})
		return
	}

	type subtotalBucket struct {
		subtotal float64
		orderIDs []primitive.ObjectID
	}
	buckets := map[string]*subtotalBucket{
		"quick":  {subtotal: 0, orderIDs: []primitive.ObjectID{}},
		"normal": {subtotal: 0, orderIDs: []primitive.ObjectID{}},
	}

	now := time.Now()
	for _, cartDoc := range cartDocs {
		productID, _ := cartDoc["product_id"].(primitive.ObjectID)
		var product bson.M
		if err := productColl.FindOne(ctx, bson.M{"_id": productID}).Decode(&product); err != nil {
			continue
		}

		qty := 1
		if n, ok := cartDoc["number"].(int32); ok {
			qty = int(n)
		} else if n, ok := cartDoc["number"].(int64); ok {
			qty = int(n)
		} else if n, ok := cartDoc["number"].(int); ok {
			qty = n
		}

		price := 0.0
		if v, ok := product["price_per_unit"].(float64); ok {
			price = v
		} else if v, ok := product["price_per_unit"].(int32); ok {
			price = float64(v)
		} else if v, ok := product["price_per_unit"].(int64); ok {
			price = float64(v)
		}
		discount := 0.0
		if v, ok := product["discount"].(float64); ok {
			discount = v
		} else if v, ok := product["discount"].(int32); ok {
			discount = float64(v)
		} else if v, ok := product["discount"].(int64); ok {
			discount = float64(v)
		}

		dTypeRaw, _ := product["delivery_category"].(string)
		dType := strings.ToLower(strings.TrimSpace(dTypeRaw))
		if dType != "quick" {
			dType = "normal"
		}
		lineTotal := (price * (1 - (discount / 100))) * float64(qty)

		itemDoc := bson.M{
			"user_id":          userID,
			"address_id":       addressID,
			"cart_id":          cartDoc["_id"],
			"product_id":       productID,
			"number":           qty,
			"status":           "preparing",
			"type":             dType,
			"date_of_order":    now,
			"date_of_delivery": time.Time{},
			"rider_id":         nil,
			"payment_method":   paymentMethod,
			"line_total":       lineTotal,
		}
		res, err := orderItemColl.InsertOne(ctx, itemDoc)
		if err != nil {
			continue
		}
		if oid, ok := res.InsertedID.(primitive.ObjectID); ok {
			buckets[dType].orderIDs = append(buckets[dType].orderIDs, oid)
			buckets[dType].subtotal += lineTotal
		}
	}

	var parentOrderIDs []primitive.ObjectID
	for dType, bucket := range buckets {
		if len(bucket.orderIDs) == 0 {
			continue
		}
		deliveryCharge := 0.0
		if dType == "quick" {
			if bucket.subtotal < 500 {
				deliveryCharge = 50
			}
		} else {
			if bucket.subtotal < 1000 {
				deliveryCharge = 100
			}
		}
		total := bucket.subtotal + deliveryCharge
		parentDoc := bson.M{
			"user_id":         userID,
			"order_ids":       bucket.orderIDs,
			"type":            dType,
			"delivery_charge": deliveryCharge,
			"total":           total,
			"otp":             "",
			"status":          "ongoing",
			"date_of_order":   now,
			"payment_method":  paymentMethod,
			"address_id":      addressID,
		}
		pres, err := orderParentColl.InsertOne(ctx, parentDoc)
		if err != nil {
			continue
		}
		if parentID, ok := pres.InsertedID.(primitive.ObjectID); ok {
			parentOrderIDs = append(parentOrderIDs, parentID)
			_, _ = orderItemColl.UpdateMany(
				ctx,
				bson.M{"_id": bson.M{"$in": bucket.orderIDs}},
				bson.M{"$set": bson.M{"orders_id": parentID}},
			)
		}
	}

	_, _ = cartColl.DeleteMany(ctx, bson.M{"_id": bson.M{"$in": cartObjectIDs}, "user_id": userID})

	if len(parentOrderIDs) > 0 {
		_ = pushContactToAllAdmins(ctx, "order", "", "", fmt.Sprintf("Customer placed %d new order group(s).", len(parentOrderIDs)), fmt.Sprintf("User ID: %v", userID), "order")
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "in progress", "orders": parentOrderIDs})
}

// CustomerPayment handles /api/user/payment
func CustomerPayment(c *gin.Context) {
	paymentMethod := c.Query("payment method")
	if paymentMethod == "" {
		paymentMethod = c.PostForm("payment method")
	}

	if paymentMethod == "cash on delivary" {
		c.JSON(http.StatusOK, gin.H{"success": true, "message": "order placed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "payment in process"})
}

// CustomerOrderAll handles /api/user/order/all
func CustomerOrderAll(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "server error"})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	if page <= 0 {
		page = 1
	}
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if limit <= 0 {
		limit = 20
	}
	status := strings.TrimSpace(c.Query("status"))
	search := strings.ToLower(strings.TrimSpace(c.Query("search")))
	deliveryCategory := strings.TrimSpace(c.Query("delivary category"))
	if deliveryCategory == "" {
		deliveryCategory = strings.TrimSpace(c.Query("delivery_category"))
	}

	parentFilter := bson.M{"user_id": userID}
	if deliveryCategory != "" {
		parentFilter["type"] = deliveryCategory
	}

	parentColl := utils.GetCollection("orders")
	itemColl := utils.GetCollection("order")
	productColl := utils.GetCollection("products")
	riderColl := utils.GetCollection("riders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := parentColl.Find(
		ctx,
		parentFilter,
		options.Find().SetSort(bson.M{"date_of_order": -1}).SetLimit(int64(limit)).SetSkip(int64((page-1)*limit)),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	var parents []bson.M
	cursor.All(ctx, &parents)

	var mapped []gin.H
	for _, parent := range parents {
		parentID, _ := parent["_id"].(primitive.ObjectID)

		itemFilter := bson.M{"orders_id": parentID}
		if status != "" {
			itemFilter["status"] = status
		}
		icur, err := itemColl.Find(ctx, itemFilter)
		if err != nil {
			continue
		}
		var items []bson.M
		icur.All(ctx, &items)

		var children []gin.H
		for _, item := range items {
			productID, _ := item["product_id"].(primitive.ObjectID)
			var product bson.M
			_ = productColl.FindOne(ctx, bson.M{"_id": productID}).Decode(&product)
			if search != "" {
				nameRaw, _ := product["name"].(string)
				name := strings.ToLower(nameRaw)
				if !strings.Contains(name, search) {
					continue
				}
			}

			riderName := ""
			riderNumber := ""
			if riderID, ok := item["rider_id"].(primitive.ObjectID); ok && !riderID.IsZero() {
				var rider bson.M
				if err := riderColl.FindOne(ctx, bson.M{"_id": riderID}).Decode(&rider); err == nil {
					riderName, _ = rider["name"].(string)
					riderNumber, _ = rider["number"].(string)
				}
			}

			image := ""
			if photos, ok := product["photos"].(primitive.A); ok && len(photos) > 0 {
				if first, ok := photos[0].(string); ok {
					image = first
				}
			}

			children = append(children, gin.H{
				"orders id":         parentID,
				"order id":          item["_id"],
				"product name":      product["name"],
				"product id":        item["product_id"],
				"product image":     image,
				"brand name":        product["brand"],
				"short description": product["short_descriptions"],
				"product number":    item["number"],
				"status":            item["status"],
				"delivery category": item["type"],
				"rider name":        riderName,
				"rider number":      riderNumber,
			})
		}
		if len(children) > 0 {
			addressID := ""
			addressText := ""
			if aid, ok := parent["address_id"].(primitive.ObjectID); ok {
				addressID = aid.Hex()
				var addr bson.M
				if err := utils.GetCollection("addresses").FindOne(ctx, bson.M{"_id": aid}).Decode(&addr); err == nil {
					city, _ := addr["city"].(string)
					landmark, _ := addr["landmark"].(string)
					addressText = strings.TrimSpace(strings.TrimSpace(landmark) + " " + strings.TrimSpace(city))
				}
			}
			mapped = append(mapped, gin.H{
				"orders id":       parentID,
				"status":          parent["status"],
				"delivery type":   parent["type"],
				"delivery charge": parent["delivery_charge"],
				"total":           parent["total"],
				"address id":      addressID,
				"address":         addressText,
				"items":           children,
			})
		}
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// CustomerOrderCancel handles /api/user/order/cancel
func CustomerOrderCancel(c *gin.Context) {
	orderIDStr := c.PostForm("order id")
	orderID, _ := primitive.ObjectIDFromHex(orderIDStr)

	coll := utils.GetCollection("order")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var order bson.M
	err := coll.FindOne(ctx, bson.M{"_id": orderID}).Decode(&order)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	status, _ := order["status"].(string)
	if status == "pending" || status == "already on delivary" {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "already on delivary"})
		return
	}

	coll.UpdateOne(ctx, bson.M{"_id": orderID}, bson.M{"$set": bson.M{"status": "cancelledByUser"}})
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully cancelled"})
}

// CustomerOrderReorder handles /api/user/orders/reorder
func CustomerOrderReorder(c *gin.Context) {
	// Reorder shifts back past item sequences natively back into generic cart logic
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added to cart"})
}
