package routes

import (
	"quixo-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetupProductRoutes(r *gin.Engine) {
	productGroup := r.Group("/api/product")
	{
		// Publicly fetchable routes that intelligently parse optional tokens inline
		productGroup.GET("/all", controllers.GetAllProducts)
		productGroup.GET("/id", controllers.GetProductByID)
		productGroup.GET("/recommended", controllers.GetRecommendedProducts)
	}
}
