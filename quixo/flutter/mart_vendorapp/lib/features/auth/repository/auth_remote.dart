import 'package:dio/dio.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/auth_model.dart';
import '../data/auth_token_model.dart';
import '../data/otp_verify_model.dart';
import '../data/business_type_model.dart';

class VenderAuthRemote {
  final DioClient dio;

  VenderAuthRemote({required this.dio});

  Future<bool> register(VenderAuthModel m, List<MultipartFile> files) async {

    FormData formData = FormData.fromMap({
      ...m.toMap(),
      if (files.isNotEmpty) "Pan file": files.first,
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

    print(phone);

    Map<String, dynamic> map = await dio.post(
       ApiEndpoints.login,
      {"phone": phone},
    );

    print("fello");
    print(map);

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

  Future<List<BusinessTypeModel>> fetchBusinessTypes() async {
    Map<String, dynamic> map = await dio.get(ApiEndpoints.businessTypes);
    
    if (checkSuccess(map)) {
      List<dynamic> data = map['data'] ?? [];
      return data.map((e) => BusinessTypeModel.fromMap(e)).toList();
    } else {
      throw const ServerFailure("Failed to fetch business types");
    }
  }
}