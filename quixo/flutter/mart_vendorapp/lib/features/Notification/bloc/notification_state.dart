import 'package:equatable/equatable.dart';
import '../data/notification_model.dart';

abstract class NotificationState extends Equatable {

  const NotificationState();

  @override
  List<Object?> get props => [];

}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {

  final List<NotificationModel> notifications;

  const NotificationLoaded({
    required this.notifications,
  });

  @override
  List<Object?> get props => [notifications];

}

class NotificationFailed extends NotificationState {

  final String message;

  const NotificationFailed({
    required this.message,
  });

  @override
  List<Object?> get props => [message];

}