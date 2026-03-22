class ApiEndpoints {
  // Base
  static const String baseImageUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ========== AUTH ==========
  static const String registration =  '/rider/registration/';
  static const String registrationOtp = '/rider/registration/otp';
  static const String login = '/rider/login/';
  static const String loginOtp = '/rider/login/otp';

  //=====Dashboard====
  static const String dashboard = '/rider/dashboard';

  //====Notification====
  static const String Notification = '/rider/notification';

  //========Orders=====
  static const String orderAll = '/user/order/all';
  static const String generateOtp = '/rider/generate_otp';
  static const String orderDelivered = '/user/order/delievered/';

  //======Profile===========
  static const String getProfile = '/rider/profile/get';
  static const String profileUpdate = '/rider/profile/update';
  static const String deleteProfile = '/rider/profile/delete';
  static const String updateProfileOtp = '/rider/profile/otp';

}
