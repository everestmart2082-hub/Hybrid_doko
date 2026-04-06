package main

import (
	"context"
	"fmt"
	"log"

	"quixo-server/utils"
	"quixo-server/models"
	"go.mongodb.org/mongo-driver/bson"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(".env"); err != nil {
		log.Println("No .env")
	}
	utils.ConnectDB()

	coll := utils.GetCollection("riders")
	cursor, err := coll.Find(context.Background(), bson.M{})
	if err != nil {
		log.Fatal(err)
	}

	var riders []models.Rider
	if err = cursor.All(context.Background(), &riders); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Found %d riders\n", len(riders))
	for _, r := range riders {
		fmt.Printf("Rider: ID=%v Name=%s Number='%s' Suspended=%v Verified=%v\n", r.ID.Hex(), r.Name, r.Number, r.Suspended, r.Verified)
	}
}
