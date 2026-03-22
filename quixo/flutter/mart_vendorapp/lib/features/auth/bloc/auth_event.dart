import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import '../data/auth_model.dart';
import '../data/otp_verify_model.dart';

abstract class VenderAuthEvent extends Equatable {
  const VenderAuthEvent();

  @override
  List<Object?> get props => [];
}

class VenderAuthCheck extends VenderAuthEvent {}

class VenderRegister extends VenderAuthEvent {
  final VenderAuthModel input;
  final List<MultipartFile> files;

  const VenderRegister({required this.input, required this.files});

  @override
  List<Object?> get props => [input, files];
}

class VenderRegisterOtpVerify extends VenderAuthEvent {
  final VenderOtpVerifyModel input;

  const VenderRegisterOtpVerify({required this.input});

  @override
  List<Object?> get props => [input];
}

class VenderLogin extends VenderAuthEvent {
  final String phone;

  const VenderLogin({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class VenderLoginOtpVerify extends VenderAuthEvent {
  final VenderOtpVerifyModel input;

  const VenderLoginOtpVerify({required this.input});

  @override
  List<Object?> get props => [input];
}

class VenderLogout extends VenderAuthEvent {}