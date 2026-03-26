package utils

import (
	"context"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var DB *mongo.Database
var MongoClient *mongo.Client

func ConnectDB() {
	uri := os.Getenv("MONGODB_URI")
	if uri == "" {
		log.Fatal("MONGODB_URI environment variable is not set")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	clientOptions := options.Client().ApplyURI(uri)
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal("Failed to connect to MongoDB:", err)
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal("Failed to ping MongoDB:", err)
	}

	log.Println("Successfully connected to MongoDB")
	
	MongoClient = client
	DB = client.Database("quixo-server")
}

func GetCollection(collectionName string) *mongo.Collection {
	return DB.Collection(collectionName)
}

func InitCollections() {
	collections := []string{
		"users", "admins", "vendors", "riders", "employees",
		"products", "order", "orders", "addresses", "categories",
		"events", "payments", "reviews", "logs", "notifications", "constants",
	}

	names, err := DB.ListCollectionNames(context.Background(), bson.D{})
	if err != nil {
		log.Println("Error listing collections:", err)
		return
	}

	exists := make(map[string]bool)
	for _, n := range names {
		exists[n] = true
	}

	for _, coll := range collections {
		if !exists[coll] {
			err := DB.CreateCollection(context.Background(), coll)
			if err != nil {
				log.Printf("Error creating collection %s: %v\n", coll, err)
			} else {
				log.Printf("Created collection: %s\n", coll)
			}
		}
	}

	// Bootstrap Default Admin Account if none exists so users can log in on fresh database install
	adminColl := DB.Collection("admins")
	count, _ := adminColl.CountDocuments(context.Background(), bson.M{})
	if count == 0 {
		adminColl.InsertOne(context.Background(), bson.M{
			"name":  "Super Admin",
			"phone": "9876543210",
			"email": "admin@quixo.com",
			"otp":   "",
		})
		log.Println("Created default admin securely bounded with phone 9876543210")
	}
}
