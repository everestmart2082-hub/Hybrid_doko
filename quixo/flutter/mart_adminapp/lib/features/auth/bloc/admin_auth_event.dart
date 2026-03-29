import 'package:equatable/equatable.dart';

abstract class AdminAuthEvent extends Equatable {
  const AdminAuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if a token is stored (app startup).
class AdminAuthCheck extends AdminAuthEvent {}

/// Step 1 of login — send phone, server sends OTP.
class AdminLogin extends AdminAuthEvent {
  final String phone;
  const AdminLogin({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Step 2 of login — submit phone + OTP to get JWT.
class AdminLoginOtpVerify extends AdminAuthEvent {
  final String phone;
  final String otp;
  const AdminLoginOtpVerify({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

/// Logout — clear stored token.
class AdminLogout extends AdminAuthEvent {}

/// Step 1 of Add Admin — send name/email/number (protected route).
class AdminAddAdmin extends AdminAuthEvent {
  final String name;
  final String email;
  final String number;
  const AdminAddAdmin(
      {required this.name, required this.email, required this.number});

  @override
  List<Object?> get props => [name, email, number];
}

/// Step 2 of Add Admin — verify OTP.
class AdminAddAdminOtpVerify extends AdminAuthEvent {
  final String number;
  final String otp;
  const AdminAddAdminOtpVerify({required this.number, required this.otp});

  @override
  List<Object?> get props => [number, otp];
}
