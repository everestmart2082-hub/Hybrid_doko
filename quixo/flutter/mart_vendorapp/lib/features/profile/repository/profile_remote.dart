
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/profile_model.dart';
import '../data/profile_delete_model.dart';

class ProfileRemote {

  final DioClient dio;

  ProfileRemote({required this.dio});

  Future<ProfileModel> getProfile() async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.profile,
      {},
    );

    checkSuccess(map);

    return ProfileModel.fromMap(map["message"]);
  }

  Future<bool> updateProfile(ProfileModel model) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.profileUpdate,
      model.toJson(),
    );

    return checkSuccess(map);
  }

  Future<bool> verifyOtp(String phone, String otp) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.profileOtp,
      {
        "phone": phone,
        "otp": otp,
      },
    );

    return checkSuccess(map);
  }

  Future<bool> deleteProfile(ProfileDeleteModel model) async {

    Map<String, dynamic> map = await dio.delete(
      ApiEndpoints.profileDelete,
      model.toJson(),
    );

    return checkSuccess(map);
  }

}