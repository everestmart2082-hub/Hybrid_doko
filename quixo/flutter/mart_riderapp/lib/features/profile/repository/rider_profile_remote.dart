
import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../data/rider_profile_update_model.dart';
import '../data/rider_profile_response_model.dart';

class RiderProfileRemote {
  final DioClient dio;

  RiderProfileRemote({required this.dio});

  /// Get Profile
  Future<RiderProfileResponseModel> getProfile() async {
    final response = await dio.post(
      ApiEndpoints.getProfile
      ,
      {}
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderProfileResponseModel.fromJson(data);
  }

  /// Update Profile
  Future<RiderProfileResponseModel> updateProfile(
      RiderProfileUpdateModel model) async {
    final response = await dio.post(
      ApiEndpoints.profileUpdate,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderProfileResponseModel.fromJson(data);
  }

  /// Delete Profile (pause/delete)
  Future<RiderProfileResponseModel> deleteProfile(
      String reason) async {
    final response = await dio.delete(
      ApiEndpoints.deleteProfile,
      {"reason": reason}
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderProfileResponseModel.fromJson(data);
  }

  /// OTP Verification for profile update
  Future<RiderProfileResponseModel> verifyOtp(String phone, String otp) async {
    final response = await dio.post(
      ApiEndpoints.updateProfileOtp,
      FormData.fromMap({"phone": phone, "otp": otp}),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return RiderProfileResponseModel.fromJson(data);
  }
}