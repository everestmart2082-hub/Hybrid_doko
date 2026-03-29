class ApiEndpoints {
  // Base
  static const String baseImageUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'http://localhost:5000/api';

  // ========== AUTH ==========
  static const String userRegister = '/user/registration';
  static const String userRegistrationOtp = '/user/registration/otp';
  static const String userLogin = '/user/login';
  static const String userLoginOtp = '/user/login/otp';

  // ==== Profile ====
  static const String profileGet = '/user/profile/get';
  static const String profileUpdate = '/user/profile/update';
  static const String profileDelete = '/user/profile/delete';
  static const String profileOtp = '/user/profile/otp';

  // ========== PRODUCT REVIEW & RATING ==========
  static const String addReview = '/user/review';
  static const String addRating = '/user/product/rating';

  //===Addresses===
  static const String getAllAddresses = '/user/address/all';
  static const String addAddress = '/user/address/add';
  static const String updateAddress = '/user/address/update';
  static const String deleteAddress = '/user/address/delete';

  //===Cart====
  static const String addCart = '/user/cart/add';
  static const String removeCart = '/user/cart/remove';

  //====Order===
  static const String getOrder = '/user/order/all';
  static const String cancelOrder = '/user/order/cancel';
  static const String reorder = '/user/orders/reorder';

  //===Notifications===
  static const String getNotifications = '/user/notification';

}
