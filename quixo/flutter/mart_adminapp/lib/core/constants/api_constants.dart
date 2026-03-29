class ApiEndpoints {
  // Base
  static const String baseImageUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ========== AUTH ==========
  static const String adminLogin = '/admin/Login/';
  static const String adminLoginOtp = '/admin/login/otp';
  static const String adminAddAdmin = '/admin/addAdmin';
  static const String adminAddAdminOtp = '/admin/addAdminOtp';

  // ========== PROFILE ==========
  static const String adminProfileGet = '/admin/profile/get';
  static const String adminProfileUpdate = '/admin/profile/update';
  static const String adminProfileOtp = '/admin/profile/otp';
  static const String adminProfileAddOtp = '/admin/profile/add/otp';
  static const String adminProfileDelete = '/admin/profile/delete';

  // ========== VENDOR MANAGEMENT ==========
  static const String adminVendorAll = '/admin/vender/all';
  static const String adminVendorApprove = '/admin/vender/approve';
  static const String adminVendorSuspension = '/admin/vender/suspension';
  static const String adminVendorBlacklist = '/admin/vender/blacklist';
  static const String adminVendorNotification = '/admin/vender/notification';
  static const String adminVendorViolations = '/admin/vender/violations/update';

  // ========== USER MANAGEMENT ==========
  static const String adminUserAll = '/admin/user/all';
  static const String adminUserApprove = '/admin/user/approve';
  static const String adminUserSuspension = '/admin/user/suspension';
  static const String adminUserBlacklist = '/admin/user/blacklist';
  static const String adminUserNotification = '/admin/user/notification';
  static const String adminUserViolations = '/admin/user/violations/update';

  // ========== RIDER MANAGEMENT ==========
  static const String adminRiderAll = '/admin/rider/all';
  static const String adminRiderApprove = '/admin/rider/approve';
  static const String adminRiderSuspension = '/admin/rider/suspension';
  static const String adminRiderBlacklist = '/admin/rider/blacklist';
  static const String adminRiderNotification = '/admin/rider/notification';
  static const String adminRiderViolations = '/admin/rider/violations/update';

  // ========== EMPLOYEE MANAGEMENT ==========
  static const String adminEmployeeAdd = '/admin/employee/add';
  static const String adminEmployeeUpdate = '/admin/employee/update';
  static const String adminEmployeeUpdateOtp = '/admin/employee/update/otp';
  static const String adminEmployeeDelete = '/admin/employee/delete';
  static const String adminEmployeeViolations = '/admin/employee/violations/update';

  // ========== PRODUCTS ==========
  static const String adminProductAll = '/admin/product/all';
  static const String adminProductById = '/admin/product/id';
  static const String adminProductApprove = '/admin/product/approve';
  static const String adminProductHide = '/admin/product/hide';

  // ========== CATEGORIES ==========
  static const String categoryAll = '/category/all'; // public — no /admin prefix
  static const String adminCategoryAdd = '/admin/categories/add';
  static const String adminCategoryEdit = '/admin/categories/edit';
  static const String adminCategoryHide = '/admin/categories/hide';

  // ========== ORDERS ==========
  static const String adminOrderAll = '/admin/order/all';

  // ========== SETTINGS / CONSTANTS ==========
  static const String adminChangeConstants = '/admin/changeConstants';
}
