import 'package:equatable/equatable.dart';
import '../data/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileSuccess extends ProfileState {}

class ProfileFailed extends ProfileState {
  final String message;

  const ProfileFailed(this.message);

  @override
  List<Object?> get props => [message];
}