package routes

import (
	"quixo-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetupCustomerRoutes(r *gin.Engine) {
	userGroup := r.Group("/api/user")
	{
		// Authentication & Registration
		userGroup.POST("/registration", controllers.CustomerRegistration)
		userGroup.POST("/registration/otp", controllers.CustomerRegistrationOTP)
		userGroup.POST("/login", controllers.CustomerLogin)
		userGroup.POST("/login/otp", controllers.CustomerLoginOTP)

		// Protected Domain
		protected := userGroup.Group("/")
		protected.Use(controllers.AuthMiddleware("user"))
		{
			// Profile Management
			protected.POST("/profile/get", controllers.CustomerProfileGet)
			protected.POST("/profile/update", controllers.CustomerProfileUpdate)
			protected.POST("/profile/otp", controllers.CustomerProfileUpdateOTP)
			protected.DELETE("/profile/delete", controllers.CustomerProfileDelete)

			// Addresses
			protected.POST("/address/add", controllers.CustomerAddAddress)
			protected.POST("/address/all", controllers.CustomerGetAllAddress)
			protected.POST("/address/update", controllers.CustomerUpdateAddress)
			protected.DELETE("/address/delete", controllers.CustomerDeleteAddress)

			// Cart
			protected.POST("/cart/get", controllers.CustomerGetCart)
			protected.POST("/cart/add", controllers.CustomerAddToCart)
			protected.DELETE("/cart/remove", controllers.CustomerRemoveFromCart)

			// Wishlists
			protected.POST("/wishlist/add", controllers.CustomerAddToWishList)
			protected.POST("/wishlist/remove", controllers.CustomerRemoveFromWishList)
			protected.POST("/wishlist/get", controllers.CustomerGetWishList)

			// Orders & Checkout
			protected.POST("/checkout", controllers.CustomerCheckout)
			protected.GET("/payment", controllers.CustomerPayment)
			protected.GET("/order/all", controllers.CustomerOrderAll)
			protected.DELETE("/order/cancel", controllers.CustomerOrderCancel)
			protected.DELETE("/orders/reorder", controllers.CustomerOrderReorder)

			// Ratings & Reviews
			protected.POST("/product/rating", controllers.CustomerProductRating)
			protected.POST("/rider/rating", controllers.CustomerRiderRating)
			protected.POST("/review", controllers.CustomerReview)

			// Messages & Notifications
			protected.POST("/sendmessage", controllers.CustomerSendMessage)
			protected.POST("/notification", controllers.CustomerNotification)
		}
	}
}
