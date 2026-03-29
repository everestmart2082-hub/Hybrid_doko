import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/profile/data/admin_profile_model.dart';

abstract class AdminProfileState extends Equatable {
  const AdminProfileState();

  @override
  List<Object?> get props => [];
}

class AdminProfileInitial extends AdminProfileState {}

class AdminProfileLoading extends AdminProfileState {}

class AdminProfileLoaded extends AdminProfileState {
  final AdminProfile profile;
  const AdminProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Update submitted, OTP step pending.
class AdminProfileUpdatePending extends AdminProfileState {}

class AdminProfileSuccess extends AdminProfileState {
  final String message;
  const AdminProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminProfileFailed extends AdminProfileState {
  final String message;
  const AdminProfileFailed(this.message);

  @override
  List<Object?> get props => [message];
}
