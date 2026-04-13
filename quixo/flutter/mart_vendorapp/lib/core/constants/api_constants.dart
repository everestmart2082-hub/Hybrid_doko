import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Base host override for real devices:
  // flutter run --dart-define=API_HOST=http://192.168.x.x:5000
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  static String get _host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  static String get baseImageUrl => _host;
  static String get baseUrl => _host;

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

  static const String contactAdmin = "/api/vender/contact/admin";

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
