import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';
import 'package:mart_adminapp/core/network/token_provider.dart';

import '../data/admin_auth_model.dart';

class AdminAuthRemote {
  final DioClient dio;

  AdminAuthRemote({required this.dio});

  // POST /admin/Login/  — sends phone, expects OTP to be sent
  Future<bool> login(String phone) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminLogin, {'phone': phone});
    return checkSuccess(map);
  }

  // POST /admin/login/otp — verifies OTP, returns JWT token
  Future<AdminAuthToken> verifyLoginOtp(AdminOtpLoginRequest req) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminLoginOtp, req.toMap());
    checkSuccess(map);
    return AdminAuthToken.fromMap({'token': map['token']});
  }

  // POST /admin/addAdmin — adds a new admin (protected, uses multipart form)
  Future<bool> addAdmin(AdminAddRequest req) async {
    final formData = FormData.fromMap(req.toMap());
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminAddAdmin, formData);
    return checkSuccess(map);
  }

  // POST /admin/addAdminOtp — verifies OTP for new admin creation
  Future<AdminAuthToken> verifyAddAdminOtp(AdminAddOtpRequest req) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminAddAdminOtp, req.toMap());
    checkSuccess(map);
    return AdminAuthToken.fromMap({'token': map['token']});
  }

  // Helper to persist the token after login
  Future<void> persistToken(String token) async {
    final provider = SharedPreferencesTokenProvider();
    await provider.setToken(token);
  }

  Future<void> clearToken() async {
    final provider = SharedPreferencesTokenProvider();
    await provider.clearToken();
  }

  Future<String?> getStoredToken() async {
    final provider = SharedPreferencesTokenProvider();
    return provider.getToken();
  }
}

