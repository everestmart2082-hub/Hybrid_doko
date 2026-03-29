import 'package:equatable/equatable.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

/// Token found in storage — user is authenticated.
class AdminAuthenticated extends AdminAuthState {
  final bool authenticated;
  const AdminAuthenticated({required this.authenticated});

  @override
  List<Object?> get props => [authenticated];
}

/// No token — user must login.
class AdminUnauthenticated extends AdminAuthState {}

/// Phone submitted, OTP sent — waiting for OTP input.
class AdminAuthOtpSent extends AdminAuthState {
  final String phone;
  const AdminAuthOtpSent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Add-admin step 1 done — waiting for OTP.
class AdminAddAdminOtpSent extends AdminAuthState {
  final String number;
  const AdminAddAdminOtpSent({required this.number});

  @override
  List<Object?> get props => [number];
}

class AdminAuthSuccess extends AdminAuthState {}

class AdminAuthFailed extends AdminAuthState {
  final String message;
  const AdminAuthFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
