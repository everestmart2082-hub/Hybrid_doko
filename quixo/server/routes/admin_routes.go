package routes

import (
	"quixo-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetupAdminRoutes(r *gin.Engine) {
	// Publicly accessible category fetcher
	r.GET("/api/category/all", controllers.GetAllCategories)

	adminGroup := r.Group("/api/admin")
	{
		adminGroup.POST("/Login/", controllers.AdminLogin)
		adminGroup.POST("/login/otp", controllers.AdminOTPLogin)
		adminGroup.POST("/addAdminOtp", controllers.AdminAddAdminOTP)

		protected := adminGroup.Group("/")
		protected.Use(controllers.AuthMiddleware("admin"))
		{
			protected.POST("/addAdmin", controllers.AdminAddAdmin)

			// Vendor Management
			protected.POST("/vender/approve", controllers.AdminVendorApprove)
			protected.POST("/vender/suspension", controllers.AdminVendorSuspension)
			protected.POST("/vender/blacklist", controllers.AdminVendorBlacklist)
			protected.GET("/vender/all", controllers.AdminGetAllVendor)

			// User Management
			protected.POST("/user/approve", controllers.AdminUserApprove)
			protected.POST("/user/suspension", controllers.AdminUserSuspension)
			protected.POST("/user/blacklist", controllers.AdminUserBlacklist)
			protected.GET("/user/all", controllers.AdminGetAllUser)

			// Rider Management
			protected.POST("/rider/approve", controllers.AdminRiderApprove)
			protected.POST("/rider/suspension", controllers.AdminRiderSuspension)
			protected.POST("/rider/blacklist", controllers.AdminRiderBlacklist)
			protected.GET("/rider/all", controllers.AdminGetAllRider)

			// Product Management
			protected.POST("/product/approve", controllers.AdminApproveProduct)
			protected.POST("/product/hide", controllers.AdminHideProduct)
			protected.GET("/product/all", controllers.AdminGetAllProduct)
			protected.GET("/product/id", controllers.AdminProductGetByID)

			// Category Management
			protected.POST("/categories/add", controllers.AdminAddCategory)
			protected.POST("/categories/edit", controllers.AdminEditCategory)
			protected.POST("/categories/hide", controllers.AdminHideCategory)

			// Employee Management
			protected.POST("/employee/add", controllers.AdminAddEmployee)
			protected.POST("/employee/update", controllers.AdminUpdateEmployee)
			protected.POST("/employee/update/otp", controllers.AdminUpdateEmployeeOTP)
			protected.DELETE("/employee/delete", controllers.AdminDeleteEmployee)
			protected.GET("/employee/all", controllers.AdminGetAllEmployees)

			// Notifications
			protected.POST("/notifications/all", controllers.AdminNotificationsAll)
			protected.POST("/vender/notification", controllers.AdminVendorNotification)
			protected.POST("/user/notification", controllers.AdminUserNotification)
			protected.POST("/rider/notification", controllers.AdminRiderNotification)

			// Violations
			protected.POST("/vender/violations/update", controllers.AdminVendorViolation)
			protected.POST("/employee/violations/update", controllers.AdminEmployeeViolation)
			protected.POST("/rider/violations/update", controllers.AdminRiderViolation)
			protected.POST("/user/violations/update", controllers.AdminUserViolation)

			// Admin Controls
			protected.POST("/profile/get", controllers.AdminProfileGet)
			protected.POST("/profile/update", controllers.AdminProfileUpdate)
			protected.POST("/profile/otp", controllers.AdminProfileOTP)
			protected.POST("/profile/add/otp", controllers.AdminProfileAddOTP)
			protected.DELETE("/profile/delete", controllers.AdminProfileDelete)
			protected.POST("/changeConstants", controllers.AdminChangeConstants)
			protected.POST("/constants/all", controllers.AdminGetAllConstants)
			protected.POST("/constants/delete", controllers.AdminDeleteConstant)
			protected.POST("/order/all", controllers.AdminOrderAll)
			protected.POST("/order/assign-rider", controllers.AdminAssignRider)
			protected.POST("/dashboard", controllers.AdminDashboard)
		}
	}
}
