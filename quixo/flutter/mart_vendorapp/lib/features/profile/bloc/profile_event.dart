import 'package:equatable/equatable.dart';
import '../data/profile_model.dart';
import '../data/profile_delete_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;

  const UpdateProfile({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class VerifyProfileOtp extends ProfileEvent {

  final String phone;
  final String otp;

  const VerifyProfileOtp({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

class DeleteProfile extends ProfileEvent {

  final ProfileDeleteModel model;

  const DeleteProfile({required this.model});

  @override
  List<Object?> get props => [model];
}