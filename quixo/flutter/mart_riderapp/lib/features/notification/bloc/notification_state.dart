import 'package:equatable/equatable.dart';
import '../data/notification_model.dart';

abstract class RiderNotificationState extends Equatable {
  const RiderNotificationState();

  @override
  List<Object?> get props => [];
}

class RiderNotificationInitial extends RiderNotificationState {}

class RiderNotificationLoading extends RiderNotificationState {}

class RiderNotificationLoaded extends RiderNotificationState {
  final List<RiderNotificationModel> notifications;

  const RiderNotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class RiderNotificationFailure extends RiderNotificationState {
  final String message;

  const RiderNotificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}