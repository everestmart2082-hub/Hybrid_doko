package controllers

import (
	"context"
	"net/http"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
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

// AdminOrderAll handles /api/admin/order/all
func AdminOrderAll(c *gin.Context) {
	coll := utils.GetCollection("orders")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{}, options.Find().SetLimit(100))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, o := range results {
		mapped = append(mapped, gin.H{
			"order id":          o["_id"],
			"order status":      o["status"],
			"product category":  o["product_category"],
			"delivary category": o["delivery_category"],
			"order time":        o["date"],
			"product id":        o["product_id"],
			"vender id":         o["vendor_id"],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": mapped,
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
