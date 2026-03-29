import 'package:equatable/equatable.dart';
import '../data/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

/// Profile data has been loaded (display screen)
class ProfileLoaded extends ProfileState {

  final ProfileModel profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// UpdateProfile was called successfully — OTP dialog should now appear
class ProfileOtpRequired extends ProfileState {}

/// OTP verified successfully — show success dialog then return to dashboard
class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Account was deleted
class ProfileDeleted extends ProfileState {}

class ProfileFailed extends ProfileState {

  final String message;

  const ProfileFailed({required this.message});

  @override
  List<Object?> get props => [message];
}