import 'package:equatable/equatable.dart';

abstract class AdminNotificationsEvent extends Equatable {
  const AdminNotificationsEvent();
  @override
  List<Object?> get props => [];
}

class AdminNotificationsLoad extends AdminNotificationsEvent {
  const AdminNotificationsLoad();
}
