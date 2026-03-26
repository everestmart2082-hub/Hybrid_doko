import 'package:equatable/equatable.dart';
import '../data/profile_model.dart';
import '../data/profile_delete_model.dart';
import '../data/profile_otp_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileGet extends ProfileEvent {}

class ProfileUpdate extends ProfileEvent {
  final ProfileModel profile;

  const ProfileUpdate(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileDelete extends ProfileEvent {
  final ProfileDeleteModel model;

  const ProfileDelete(this.model);

  @override
  List<Object?> get props => [model];
}

class ProfileVerifyOtp extends ProfileEvent {
  final ProfileOtpModel model;

  const ProfileVerifyOtp(this.model);

  @override
  List<Object?> get props => [model];
}