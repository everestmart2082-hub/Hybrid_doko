import 'package:equatable/equatable.dart';
import '../data/rider_login_model.dart';
import '../data/rider_model.dart';
import '../data/rider_otp_model.dart';

abstract class RiderAuthEvent extends Equatable {
  const RiderAuthEvent();

  @override
  List<Object?> get props => [];
}

class RiderRegisterRequested extends RiderAuthEvent {
  final RiderRegistrationModel model;

  const RiderRegisterRequested(this.model);

  @override
  List<Object?> get props => [model];
}

class RiderRegistrationOtpRequested extends RiderAuthEvent {
  final RiderOtpModel model;

  const RiderRegistrationOtpRequested(this.model);

  @override
  List<Object?> get props => [model];
}

class RiderLoginRequested extends RiderAuthEvent {
  final RiderLoginModel model;

  const RiderLoginRequested(this.model);

  @override
  List<Object?> get props => [model];
}

class RiderLoginOtpRequested extends RiderAuthEvent {
  final RiderOtpModel model;

  const RiderLoginOtpRequested(this.model);

  @override
  List<Object?> get props => [model];
}


class AuthCheck extends RiderAuthEvent{}


class RiderAuthLogout extends RiderAuthEvent{}
