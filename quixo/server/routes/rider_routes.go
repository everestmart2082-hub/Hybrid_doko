package routes

import (
	"quixo-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetupRiderRoutes(r *gin.Engine) {
	riderGroup := r.Group("/api/rider")
	{
		// Authentication & Registration
		riderGroup.POST("/registration", controllers.RiderRegistration)
		riderGroup.POST("/registration/otp", controllers.RiderRegistrationOTP)
		riderGroup.POST("/login", controllers.RiderLogin)
		riderGroup.POST("/login/otp", controllers.RiderLoginOTP)

		protected := riderGroup.Group("/")
		protected.Use(controllers.AuthMiddleware("rider"))
		{
			// Profile & Dashboard
			protected.POST("/profile/get", controllers.RiderProfileGet)
			protected.POST("/profile/update", controllers.RiderProfileUpdate)
			protected.POST("/profile/otp", controllers.RiderProfileOTP)
			protected.DELETE("/profile/delete", controllers.RiderProfileDelete)
			protected.POST("/dashboard", controllers.RiderDashboard)
			protected.POST("/notification", controllers.RiderNotification)
			protected.POST("/message", controllers.RiderSendMessage) // Matches /api/rider/message schema

			// Order Deliveries
			protected.POST("/order/all", controllers.RiderOrderAll)
			protected.POST("/order/accept", controllers.RiderAcceptOrder)
			protected.POST("/generate_otp", controllers.RiderGenerateOTP)
			protected.POST("/order/delivered", controllers.RiderDeliverProduct)
			protected.POST("/order/reject", controllers.RiderRejectOrder)
		}
	}
}
