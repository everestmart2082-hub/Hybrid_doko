import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/notifications/data/admin_notification_model.dart';

abstract class AdminNotificationsState extends Equatable {
  const AdminNotificationsState();
  @override
  List<Object?> get props => [];
}

class AdminNotificationsInitial extends AdminNotificationsState {
  const AdminNotificationsInitial();
}

class AdminNotificationsLoading extends AdminNotificationsState {
  const AdminNotificationsLoading();
}

class AdminNotificationsLoaded extends AdminNotificationsState {
  final List<AdminNotificationItem> items;

  const AdminNotificationsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class AdminNotificationsFailed extends AdminNotificationsState {
  final String message;

  const AdminNotificationsFailed(this.message);

  @override
  List<Object?> get props => [message];
}
