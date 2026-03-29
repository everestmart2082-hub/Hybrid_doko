package main

import (
	"log"
	"os"

	"quixo-server/routes"
	"quixo-server/utils"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

// corsMiddleware allows cross-origin requests from any origin.
// Required for Flutter web running on a different port (e.g. localhost:59502)
// calling the API on localhost:5000.
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With")
		c.Header("Access-Control-Expose-Headers", "Content-Length")
		c.Header("Access-Control-Allow-Credentials", "false")

		// Handle preflight OPTIONS request immediately
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

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

	// ── CORS ─────────────────────────────────────────────────────────────────
	// Must be registered BEFORE all routes so preflight OPTIONS requests are
	// handled correctly and every API response carries the right headers.
	r.Use(corsMiddleware())

	// Gin only runs middleware for matched routes. Register a wildcard OPTIONS
	// route so every browser preflight gets a 204 instead of a 404.
	r.OPTIONS("/*path", func(c *gin.Context) {
		c.AbortWithStatus(204)
	})

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
