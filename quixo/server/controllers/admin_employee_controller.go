package controllers

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"quixo-server/models"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// AdminAddEmployee handles /api/admin/employee/add
func AdminAddEmployee(c *gin.Context) {
	name := c.PostForm("name")
	position := c.PostForm("position")
	salaryStr := c.PostForm("salary")
	address := c.PostForm("address")
	email := c.PostForm("email")
	phone := c.PostForm("phone")
	bankName := c.PostForm("bank name")
	accountNumber := c.PostForm("account number")
	pan := c.PostForm("pan")

	// File uploads
	citizenshipFile, _ := c.FormFile("citizenship")
	var citizenshipPath string
	if citizenshipFile != nil {
		citizenshipPath, _ = utils.SaveUploadedFile(citizenshipFile)
	}

	coll := utils.GetCollection("employees")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	salary, _ := strconv.ParseFloat(salaryStr, 64)

	emp := models.Employee{
		ID:              primitive.NewObjectID(),
		Position:        position,
		Salary:          salary,
		Name:            name,
		Address:         address,
		Email:           email,
		Phone:           phone,
		CitizenshipFile: citizenshipPath,
		BankName:        bankName,
		AccountNumber:   accountNumber,
		PanFile:         pan,
	}

	_, err := coll.InsertOne(ctx, emp)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully added"})
}

// AdminUpdateEmployee handles /api/admin/employee/update
func AdminUpdateEmployee(c *gin.Context) {
	name := c.PostForm("name")
	position := c.PostForm("position")
	salaryStr := c.PostForm("salary")
	address := c.PostForm("address")
	email := c.PostForm("email")
	phone := c.PostForm("phone")
	bankName := c.PostForm("bank name")
	accountNumber := c.PostForm("account number")
	ifscCode := c.PostForm("ifsc code")
	pan := c.PostForm("pan")
	// The employee update spec doesn't require an employee ID field! 
	// This usually means phone/email acts as identity, we'll use phone.

	citizenshipFile, _ := c.FormFile("citizenship file")
	var citizenshipPath string
	if citizenshipFile != nil {
		citizenshipPath, _ = utils.SaveUploadedFile(citizenshipFile)
	}

	coll := utils.GetCollection("employees")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	salary, _ := strconv.ParseFloat(salaryStr, 64)

	update := bson.M{
		"name":            name,
		"position":        position,
		"salary":          salary,
		"address":         address,
		"email":           email,
		"bank name":       bankName,     // Note dynamic field alignment for DB 
		"account_number":  accountNumber,
		"ifsc":            ifscCode,
		"pan_file":        pan,
	}

	if citizenshipPath != "" {
		update["citizenship_file"] = citizenshipPath
	}

	_, err := coll.UpdateOne(ctx, bson.M{"phone": phone}, bson.M{"$set": update})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully updated"})
}

// AdminDeleteEmployee handles /api/admin/employee/delete
func AdminDeleteEmployee(c *gin.Context) {
	empIDStr := c.PostForm("employee id")
	empID, _ := primitive.ObjectIDFromHex(empIDStr)

	coll := utils.GetCollection("employees")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.DeleteOne(ctx, bson.M{"_id": empID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "successfully deleted"})
}

// AdminUpdateEmployeeOTP handles /api/admin/employee/update/otp
func AdminUpdateEmployeeOTP(c *gin.Context) {
	otp := c.PostForm("otp")
	phone := c.PostForm("phone")

	coll := utils.GetCollection("employees")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := coll.UpdateOne(ctx, bson.M{"phone": phone, "otp": otp}, bson.M{"$unset": bson.M{"otp": ""}})
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"success": false, "message": "otp verification failure"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "success"})
}
