
import 'package:dio/dio.dart';
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

    final raw = map['data'];
    if (raw is Map) {
      return ProfileModel.fromMap(Map<String, dynamic>.from(raw));
    }
    throw Exception(map['message']?.toString() ?? 'Invalid profile response');
  }

  Future<bool> updateProfile(ProfileModel model) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.profileUpdate,
      FormData.fromMap(model.toMap()),
    );

    return checkSuccess(map);
  }

  Future<bool> verifyOtp(String phone, String otp) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.profileOtp,
      FormData.fromMap({
        "phone": phone,
        "otp": otp,
      }),
    );

    return checkSuccess(map);
  }

  Future<bool> deleteProfile(ProfileDeleteModel model) async {

    final encodedReason = Uri.encodeComponent(model.reason);
    Map<String, dynamic> map = await dio.delete(
      "${ApiEndpoints.profileDelete}?reason=$encodedReason",
      {},
    );

    return checkSuccess(map);
  }

}