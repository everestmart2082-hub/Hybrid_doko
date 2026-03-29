

import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';
import 'package:quickmartcustomer/features/auth/data/auth_model_input.dart';
import 'package:quickmartcustomer/features/auth/data/auth_token.dart';
import 'package:quickmartcustomer/features/auth/data/otp_verify_model_input.dart';

class AuthRemote {
  final DioClient dio;

  AuthRemote({required this.dio});

  Future<AuthToken> verifyRegisterOtp(OtpVerifyModel otpf) async{
    Map<String, dynamic> map = await dio.post(ApiEndpoints.userRegistrationOtp, otpf.toFormData());
    checkSuccess(map);
    AuthToken t = AuthToken(token: map["token"]);
    return t;
  }

  Future<bool> register(AuthModel m) async{
    Map<String, dynamic> map = await dio.post(ApiEndpoints.userRegister, m.toFormData());
    var b = checkSuccess(map);
    return b;
  }

  Future<AuthToken> verifyLoginOtp(OtpVerifyModel otpf) async{
    Map<String, dynamic> map = await dio.post(ApiEndpoints.userLoginOtp, otpf.toFormData());
    checkSuccess(map);
    AuthToken t = AuthToken(token: map["token"]);
    return t;
  }

  Future<bool> login(AuthModel m) async{
    Map<String, dynamic> map = await dio.post(ApiEndpoints.userLogin, m.toFormData());
    var b = checkSuccess(map);
    return b;
  }
}