import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';

import '../data/profile_model.dart';
import '../data/profile_delete_model.dart';
import '../data/profile_otp_model.dart';

class ProfileRemote {
  final DioClient dio;

  ProfileRemote({required this.dio});

  Future<ProfileModel> getProfile() async {
    final map = await dio.post(ApiEndpoints.profileGet, {});
    checkSuccess(map);
    return ProfileModel.fromMap(map["message"]);
  }

  Future<bool> updateProfile(ProfileModel model) async {
    final map = await dio.post(ApiEndpoints.profileUpdate, model.toFormData());
    return checkSuccess(map);
  }

  Future<bool> deleteProfile(ProfileDeleteModel model) async {
    final map = await dio.post(ApiEndpoints.profileDelete, model.toFormData());
    return checkSuccess(map);
  }

  Future<bool> verifyProfileOtp(ProfileOtpModel model) async {
    final map = await dio.post(ApiEndpoints.profileOtp, model.toFormData());
    return checkSuccess(map);
  }
}
