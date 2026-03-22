class ApiEndpoints {
  // Base
  static const String baseImageUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'http://10.0.2.2:5000';

  // ========== AUTH ==========
  static const String register = "/api/vender/registration/";
  static const String registerOtp = "/api/vender/registration/otp";
  static const String login = "/api/vender/login/";
  static const String loginOtp = "/api/vender/login/otp";

  //=========Profile=======
  static const String profile = "/api/vender/profile/get";
  static const String profileOtp = "/api/vender/profile/otp";
  static const String profileDelete = "/api/vender/profile/delete";
  static const String profileUpdate = "/api/vender/profile/update";

  //==========Notification==========
  static const String notification =  "/api/rider/notification";

  //=========Products==========
  static const String products = "/api/product/all";
  static const String productById = "/api/product/id";
  static const String addProduct =  "/api/vender/product/add";
  static const String editProduct = "/api/vender/product/edit";
  static const String deleteProduct = "/api/vender/product/delete";

  //============Order================
  static const String order = "/api/vender/order/all";
  static const String orderPrepared = "/api/vender/order/prepared";

}
