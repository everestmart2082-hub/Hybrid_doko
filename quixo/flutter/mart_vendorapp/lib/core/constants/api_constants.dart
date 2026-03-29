class ApiEndpoints {
  // Base
  static const String baseImageUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = "http://localhost:5000";//'http://10.0.2.2:5000';

  // ========== AUTH ==========
  static const String register = "/api/vender/registration/";
  static const String registerOtp = "/api/vender/registration/otp";
  static const String login = "/api/vender/login/";
  static const String loginOtp = "/api/vender/login/otp";

  // ========== INIT / DASHBOARD ==========
  static const String businessTypes = "/api/vender/businessTypes";
  static const String chartMonth = "/api/vender/chart/month";

  // ========= PROFILE =======
  static const String profile = "/api/vender/profile"; // Fixed from /api/vender/profile/get
  static const String profileOtp = "/api/vender/profile/otp";
  static const String profileDelete = "/api/vender/profile/delete";
  static const String profileUpdate = "/api/vender/profile/update";

  // ========== NOTIFICATION ==========
  static const String notification = "/api/vender/notification";

  // ========= PRODUCTS ==========
  static const String products = "/api/product/all";
  static const String productById = "/api/product/id";
  static const String addProduct = "/api/vender/product/add";
  static const String editProduct = "/api/vender/product/edit";
  static const String deleteProduct = "/api/vender/product/delete";

  // ============ ORDERS ================
  static const String order = "/api/vender/order/all";
  static const String orderPrepared = "/api/vender/order/prepared/"; // Matches explicit backend path structure
}
