import 'package:dio/dio.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/auth_model.dart';
import '../data/auth_token_model.dart';
import '../data/otp_verify_model.dart';

class VenderAuthRemote {
  final DioClient dio;

  VenderAuthRemote({required this.dio});

  Future<bool> register(VenderAuthModel m, List<MultipartFile> files) async {

    FormData formData = FormData.fromMap({
      ...m.toMap(),
      "files": files
    });

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.register,
      formData,
    );

    return checkSuccess(map);
  }

  Future<VenderAuthToken> verifyRegisterOtp(VenderOtpVerifyModel otp) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.registerOtp,
      otp.toJson(),
    );

    checkSuccess(map);

    return VenderAuthToken.fromMap({
      "token": map["token"]
    });
  }

  Future<bool> login(String phone) async {

    Map<String, dynamic> map = await dio.post(
       ApiEndpoints.login,
      {"phone": phone},
    );

    return checkSuccess(map);
  }

  Future<VenderAuthToken> verifyLoginOtp(VenderOtpVerifyModel otp) async {

    Map<String, dynamic> map = await dio.post(
       ApiEndpoints.loginOtp,
      otp.toJson(),
    );

    checkSuccess(map);

    return VenderAuthToken.fromMap({
      "token": map["token"]
    });
  }
}