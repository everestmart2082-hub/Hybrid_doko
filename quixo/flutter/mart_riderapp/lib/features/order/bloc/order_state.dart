import 'package:equatable/equatable.dart';

import '../data/order_model.dart';

abstract class RiderOrderState extends Equatable {
  const RiderOrderState();
  @override
  List<Object?> get props => [];
}

class RiderOrderInitial extends RiderOrderState {}
class RiderOrderLoading extends RiderOrderState {}
class RiderOrderLoaded extends RiderOrderState {
  final List<RiderOrderGroup> orders;
  const RiderOrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class RiderOrderOtpGenerated extends RiderOrderState {
  final String message;
  const RiderOrderOtpGenerated(this.message);

  @override
  List<Object?> get props => [message];
}

class RiderOrderDeliveredSuccess extends RiderOrderState {
  final String message;
  const RiderOrderDeliveredSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RiderOrderFailure extends RiderOrderState {
  final String message;
  const RiderOrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}