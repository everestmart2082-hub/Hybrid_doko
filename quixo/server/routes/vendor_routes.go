package routes

import (
	"quixo-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetupVendorRoutes(r *gin.Engine) {
	venderGroup := r.Group("/api/vender")
	{
		venderGroup.POST("/login/", controllers.VendorLogin)
		venderGroup.POST("/login/otp", controllers.VendorOTPLogin)
		venderGroup.POST("/registration/", controllers.VendorRegistration)
		venderGroup.POST("/registration/otp", controllers.VendorRegistrationOTP)
		// Public endpoint
		venderGroup.GET("/businessTypes", controllers.VendorBusinessTypes)

		protected := venderGroup.Group("/")
		protected.Use(controllers.AuthMiddleware("vendor"))
		{
			protected.POST("/chart/month", controllers.VendorChartMonth)

			protected.POST("/product/add", controllers.VendorProductAdd)
			protected.POST("/product/edit", controllers.VendorProductEdit)
			protected.DELETE("/product/delete", controllers.VendorProductDelete)

			protected.POST("/order/all", controllers.VendorOrderAll)
			//protected.POST("/order/assign-rider", controllers.VendorAssignRider)
			protected.POST("/order/prepared/", controllers.VendorOrderPrepared)

			protected.POST("/profile/update", controllers.VendorProfileUpdate)
			protected.POST("/profile/otp", controllers.VendorProfileUpdateOTP)
			protected.DELETE("/profile/delete", controllers.VendorProfileDelete)
			protected.POST("/profile", controllers.VendorProfileGet)
			protected.POST("/notification", controllers.VendorNotification)
			protected.POST("/contact/admin", controllers.VendorContactAdmin)
		}
	}
}
