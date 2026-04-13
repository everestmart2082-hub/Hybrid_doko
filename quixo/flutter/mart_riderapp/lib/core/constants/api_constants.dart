import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Optional override for physical devices:
  // flutter run --dart-define=API_HOST=http://192.168.x.x:5000
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  // Base
  static String get _host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  static String get baseImageUrl => _host;
  static String get baseUrl => '$_host/api';

  // ========== AUTH ==========
  static const String registration =  '/rider/registration';
  static const String registrationOtp = '/rider/registration/otp';
  static const String login = '/rider/login';
  static const String loginOtp = '/rider/login/otp';

  //=====Dashboard====
  static const String dashboard = '/rider/dashboard';

  //====Notification====
  static const String Notification = '/rider/notification';

  //========Orders=====
  static const String orderAll = '/rider/order/all';
  static const String generateOtp = '/rider/generate_otp';
  static const String orderDelivered = '/rider/order/delivered';
  static const String orderAccept = '/rider/order/accept';
  static const String orderReject = '/rider/order/reject';

  //======Profile===========
  static const String getProfile = '/rider/profile/get';
  static const String profileUpdate = '/rider/profile/update';
  static const String deleteProfile = '/rider/profile/delete';
  static const String updateProfileOtp = '/rider/profile/otp';

  //======Messaging===========
  static const String riderMessage = '/rider/message';

}
