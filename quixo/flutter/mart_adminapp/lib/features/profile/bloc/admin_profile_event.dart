import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/profile/data/admin_profile_model.dart';

abstract class AdminProfileEvent extends Equatable {
  const AdminProfileEvent();

  @override
  List<Object?> get props => [];
}

class AdminProfileLoad extends AdminProfileEvent {}

class AdminProfileUpdate extends AdminProfileEvent {
  final AdminProfileUpdateRequest req;
  const AdminProfileUpdate(this.req);

  @override
  List<Object?> get props => [req];
}

class AdminProfileOtpVerify extends AdminProfileEvent {
  final String otp;
  const AdminProfileOtpVerify(this.otp);

  @override
  List<Object?> get props => [otp];
}

class AdminProfileDelete extends AdminProfileEvent {
  final AdminProfileDeleteRequest req;
  const AdminProfileDelete(this.req);

  @override
  List<Object?> get props => [req];
}

class AdminAddNewAdmin extends AdminProfileEvent {
  final String name;
  final String email;
  final String number;
  const AdminAddNewAdmin(
      {required this.name, required this.email, required this.number});

  @override
  List<Object?> get props => [name, email, number];
}

class AdminAddNewAdminOtpVerify extends AdminProfileEvent {
  final String phone;
  final String otp;
  const AdminAddNewAdminOtpVerify({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}
