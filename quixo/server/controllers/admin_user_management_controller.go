package controllers

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Reusable State Changer
func handleStateChange(c *gin.Context, collName, idField, dbField, reqField, trueMsg, falseMsg string) {
	idStr := c.PostForm(idField)
	stateStr := c.PostForm(reqField)
	id, _ := primitive.ObjectIDFromHex(idStr)
	state, _ := strconv.ParseBool(stateStr)

	coll := utils.GetCollection(collName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{dbField: state}})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	msg := trueMsg
	if !state {
		msg = falseMsg
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": msg})
}

// Reusable Fetcher
func handleGetAll(c *gin.Context, collName, idKey string) {
	coll := utils.GetCollection(collName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, _ := coll.Find(ctx, bson.M{}, options.Find().SetLimit(100))
	var results []bson.M
	cursor.All(ctx, &results)

	var mapped []gin.H
	for _, v := range results {
		mapped = append(mapped, gin.H{
			idKey:           v["_id"],
			"name":          v["name"],
			"violations":    v["violations"],
			"status":        v["verified"],
			"updateRequest": v["updation_requested"],
		})
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": mapped})
}

// --- VENDOR ---
func AdminVendorApprove(c *gin.Context) { handleStateChange(c, "vendors", "vender id", "verified", "approved", "successfully approved", "desapproved") }
func AdminVendorSuspension(c *gin.Context) { handleStateChange(c, "vendors", "vender id", "suspended", "suspended", "successfully suspended", "removed from suspension") }
func AdminVendorBlacklist(c *gin.Context) { handleStateChange(c, "vendors", "vender id", "blacklisted", "blacklisted", "successfully balcklisted", "removed from blacklist") }
func AdminGetAllVendor(c *gin.Context) { handleGetAll(c, "vendors", "vender id") }

// --- USER ---
func AdminUserApprove(c *gin.Context) { handleStateChange(c, "users", "user id", "verified", "approved", "successfully approved", "desapproved") }
func AdminUserSuspension(c *gin.Context) { handleStateChange(c, "users", "user id", "suspended", "suspended", "successfully suspended", "removed from suspension") }
func AdminUserBlacklist(c *gin.Context) { handleStateChange(c, "users", "user id", "blacklisted", "blacklisted", "successfully balcklisted", "removed from blacklist") }
func AdminGetAllUser(c *gin.Context) { handleGetAll(c, "users", "user id") }

// --- RIDER ---
func AdminRiderApprove(c *gin.Context) { handleStateChange(c, "riders", "rider id", "verified", "approved", "successfully approved", "desapproved") }
func AdminRiderSuspension(c *gin.Context) { handleStateChange(c, "riders", "rider id", "suspended", "suspended", "successfully suspended", "removed from suspension") }
func AdminRiderBlacklist(c *gin.Context) { handleStateChange(c, "riders", "rider id", "blacklisted", "blacklisted", "successfully balcklisted", "removed from blacklist") }
func AdminGetAllRider(c *gin.Context) { handleGetAll(c, "riders", "rider id") }
