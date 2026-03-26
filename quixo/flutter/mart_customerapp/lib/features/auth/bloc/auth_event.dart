import 'package:equatable/equatable.dart';
import 'package:quickmartcustomer/features/auth/data/auth_model_input.dart';
import 'package:quickmartcustomer/features/auth/data/otp_verify_model_input.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}


class AuthCheck extends AuthEvent{}


class AuthLogin extends AuthEvent{
  final AuthModel input;

  const AuthLogin({required this.input});

  
  @override
  List<Object?> get props => [input];
}


class AuthLoginOtpVerify extends AuthEvent{
  final OtpVerifyModel input;

  const AuthLoginOtpVerify({required this.input});

  
  @override
  List<Object?> get props => [input];
}


class AuthregisterOtpVerify extends AuthEvent{
  final OtpVerifyModel input;

  const AuthregisterOtpVerify({required this.input});

  
  @override
  List<Object?> get props => [input];
}


class AuthRegister extends AuthEvent{
  final AuthModel input;

  const AuthRegister({required this.input});

  
  @override
  List<Object?> get props => [input];
}


class AuthLogout extends AuthEvent{}