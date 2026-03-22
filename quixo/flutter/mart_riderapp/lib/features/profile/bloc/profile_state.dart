import 'package:equatable/equatable.dart';
import '../data/rider_profile_model.dart';

abstract class RiderProfileState extends Equatable {
  const RiderProfileState();
  @override
  List<Object?> get props => [];
}

class RiderProfileInitial extends RiderProfileState {}
class RiderProfileLoading extends RiderProfileState {}
class RiderProfileLoaded extends RiderProfileState {
  final RiderProfileModel profile;
  const RiderProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}
class RiderProfileSuccess extends RiderProfileState {
  final String message;
  const RiderProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
class RiderProfileFailure extends RiderProfileState {
  final String message;
  const RiderProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}