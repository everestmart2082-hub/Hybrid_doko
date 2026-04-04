import 'dart:convert';

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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data == null) {
      throw const ServerFailure('Empty response');
    }
    if (data is String) {
      final decoded = json.decode(data);
      if (decoded is! Map) {
        throw const ServerFailure('Invalid JSON response');
      }
      return Map<String, dynamic>.from(decoded);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    throw ServerFailure('Unexpected response type: ${data.runtimeType}');
  }

  Future<bool> register(VenderAuthModel m, List<MultipartFile> files) async {

    FormData formData = FormData.fromMap({
      ...m.toMap(),
      if (files.isNotEmpty) "Pan file": files.first,
    });

    final map = _asMap(await dio.post(
      ApiEndpoints.register,
      formData,
    ));

    return checkSuccess(map);
  }

  Future<VenderAuthToken> verifyRegisterOtp(VenderOtpVerifyModel otp) async {

    final map = _asMap(await dio.post(
      ApiEndpoints.registerOtp,
      FormData.fromMap(otp.toMap()),
    ));

    checkSuccess(map);

    return VenderAuthToken.fromMap({
      "token": map["token"],
      "id": map["id"],
    });
  }

  Future<bool> login(String phone) async {
    final map = _asMap(await dio.post(
      ApiEndpoints.login,
      FormData.fromMap({"phone": phone}),
    ));

    return checkSuccess(map);
  }

  Future<VenderAuthToken> verifyLoginOtp(VenderOtpVerifyModel otp) async {

    final map = _asMap(await dio.post(
      ApiEndpoints.loginOtp,
      FormData.fromMap(otp.toMap()),
    ));

    checkSuccess(map);

    return VenderAuthToken.fromMap({
      "token": map["token"],
      "id": map["id"],
    });
  }

  Future<List<BusinessTypeModel>> fetchBusinessTypes() async {
    final map = _asMap(await dio.get(ApiEndpoints.businessTypes));
    
    if (checkSuccess(map)) {
      List<dynamic> data = map['data'] ?? [];
      return data.map((e) => BusinessTypeModel.fromMap(e)).toList();
    } else {
      throw const ServerFailure("Failed to fetch business types");
    }
  }
}