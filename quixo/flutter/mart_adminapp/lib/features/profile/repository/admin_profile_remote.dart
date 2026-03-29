import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_profile_model.dart';

class AdminProfileRemote {
  final DioClient dio;

  AdminProfileRemote({required this.dio});

  // POST /admin/profile/get — requires auth token (set by DioClient interceptor)
  Future<AdminProfile> getProfile() async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminProfileGet, {});
    checkSuccess(map);
    // Server wraps data inside "message": { "name":..., "number":..., "email":... }
    final data = map['message'] as Map<String, dynamic>;
    return AdminProfile.fromMap(data);
  }

  // POST /admin/profile/update — stores proposed update + generates OTP
  Future<bool> updateProfile(AdminProfileUpdateRequest req) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminProfileUpdate, req.toMap());
    return checkSuccess(map);
  }

  // POST /admin/profile/otp — verifies OTP to commit profile update
  Future<bool> verifyUpdateOtp(String otp) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminProfileOtp, {'otp': otp});
    return checkSuccess(map);
  }

  // POST /admin/profile/add/otp — verifies OTP for admin addition flow
  Future<bool> verifyAddOtp(String phone, String otp) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminProfileAddOtp,
      {'phone': phone, 'otp': otp},
    );
    return checkSuccess(map);
  }

  // DELETE /admin/profile/delete — delete or suspend own account
  Future<bool> deleteProfile(AdminProfileDeleteRequest req) async {
    final Map<String, dynamic> map =
        await dio.delete(ApiEndpoints.adminProfileDelete, req.toMap());
    return checkSuccess(map);
  }
}
