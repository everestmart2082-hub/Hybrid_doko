package main

import (
	"log"
	"os"

	"quixo-server/routes"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	if err := godotenv.Load(".env"); err != nil {
		log.Println("Warning: No .env file found, relying on environment variables.")
	}

	// Connect to MongoDB
	utils.ConnectDB()

	// Initialize collections so they are visible in MongoDB GUI
	utils.InitCollections()

	// Initialize Gin router
	r := gin.Default()

	// Serve static files from the uploads directory
	r.Static("/uploads", "./uploads")

	// Register API Routes
	routes.SetupAdminRoutes(r)
	routes.SetupVendorRoutes(r)
	routes.SetupCustomerRoutes(r)
	routes.SetupProductRoutes(r)
	routes.SetupRiderRoutes(r)

	// Simple ping route
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	// Run the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "5000"
	}
	
	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server: ", err)
	}
}
