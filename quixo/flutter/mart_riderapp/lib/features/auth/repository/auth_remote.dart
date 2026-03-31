
import 'package:quickmartrider/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../data/rider_model.dart';
import '../data/rider_login_model.dart';
import '../data/rider_otp_model.dart';
import '../data/rider_auth_response_model.dart';

class RiderAuthRemote {
  final DioClient dio;

  RiderAuthRemote({required this.dio});

  /// Registration with file upload
  Future<RiderAuthResponseModel> register(
      RiderRegistrationModel model) async {
    final formData = await model.toFormData();
    final response = await dio.postWithFile(
      ApiEndpoints.registration,
      formData,
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderAuthResponseModel.fromJson(data);
  }

  /// Registration OTP
  Future<RiderAuthResponseModel> verifyRegistrationOtp(
      RiderOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.registrationOtp,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderAuthResponseModel.fromJson(data);
  }

  /// Login
  Future<RiderAuthResponseModel> login(RiderLoginModel model) async {
    final response = await dio.post(
      ApiEndpoints.login,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderAuthResponseModel.fromJson(data);
  }

  /// Login OTP
  Future<RiderAuthResponseModel> verifyLoginOtp(RiderOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.loginOtp,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderAuthResponseModel.fromJson(data);
  }
}