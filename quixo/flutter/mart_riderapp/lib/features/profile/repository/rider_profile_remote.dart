
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

    return RiderProfileResponseModel.fromJson(response.data);
  }

  /// Update Profile
  Future<RiderProfileResponseModel> updateProfile(
      RiderProfileUpdateModel model) async {
    final response = await dio.post(
      ApiEndpoints.profileUpdate,
      model.toJson(),
    );

    return RiderProfileResponseModel.fromJson(response.data);
  }

  /// Delete Profile (pause/delete)
  Future<RiderProfileResponseModel> deleteProfile(
      String reason) async {
    final response = await dio.delete(
      ApiEndpoints.deleteProfile,
      {"reason": reason}
    );

    return RiderProfileResponseModel.fromJson(response.data);
  }

  /// OTP Verification for profile update
  Future<RiderProfileResponseModel> verifyOtp(String phone, String otp) async {
    final response = await dio.post(
      ApiEndpoints.updateProfileOtp,
      {"phone": phone, "otp": otp},
    );

    return RiderProfileResponseModel.fromJson(response.data);
  }
}