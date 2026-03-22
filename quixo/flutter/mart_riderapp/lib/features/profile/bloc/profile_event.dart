import 'package:equatable/equatable.dart';
import '../data/rider_profile_update_model.dart';

abstract class RiderProfileEvent extends Equatable {
  const RiderProfileEvent();
  @override
  List<Object?> get props => [];
}

class RiderProfileFetchRequested extends RiderProfileEvent {
}

class RiderProfileUpdateRequested extends RiderProfileEvent {
  
  final RiderProfileUpdateModel model;
  const RiderProfileUpdateRequested( this.model);

  @override
  List<Object?> get props => [model];
}

class RiderProfileDeleteRequested extends RiderProfileEvent {
  final String reason;
  const RiderProfileDeleteRequested( this.reason);

  @override
  List<Object?> get props => [reason];
}

class RiderProfileOtpRequested extends RiderProfileEvent {
  final String phone;
  final String otp;
  const RiderProfileOtpRequested(this.phone, this.otp);

  @override
  List<Object?> get props => [phone, otp];
}