import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';
import 'package:quickmartcustomer/core/network/shared_pref.dart';
import '../data/profile_model.dart';
import '../data/profile_delete_model.dart';
import '../data/profile_otp_model.dart';

class ProfileRemote {
  final DioClient dio;
  final SharedPreferencesProvider s = SharedPreferencesProvider();

  ProfileRemote({
    required this.dio,
  });

  Future<String> _getToken() async {
    final token = await s.getKey(prefs.token.name);

    if (token == null || token.isEmpty) {
      throw AuthFailure("Token not found");
    }

    return token;
  }

  Future<ProfileModel> getProfile() async {
    final token = await _getToken();

    final map = await dio.post(
      ApiEndpoints.baseUrl + ApiEndpoints.profileGet,
      {"token": token},
    );

    checkSuccess(map);

    return ProfileModel.fromMap(map["message"]);
  }

  Future<bool> updateProfile(ProfileModel model) async {
    final token = await _getToken();

    final body = model.toMap();
    body["token"] = token;

    final map = await dio.post(
      ApiEndpoints.baseUrl + ApiEndpoints.profileUpdate,
      body,
    );

    return checkSuccess(map);
  }

  Future<bool> deleteProfile(ProfileDeleteModel model) async {
    final token = await _getToken();

    final body = model.toMap();
    body["token"] = token;

    final map = await dio.delete(
      ApiEndpoints.baseUrl + ApiEndpoints.profileDelete,
      body,
    );

    return checkSuccess(map);
  }

  Future<bool> verifyProfileOtp(ProfileOtpModel model) async {
    final token = await _getToken();

    final body = model.toMap();
    body["token"] = token;

    final map = await dio.post(
      ApiEndpoints.baseUrl + ApiEndpoints.profileOtp,
      body,
    );

    return checkSuccess(map);
  }
}