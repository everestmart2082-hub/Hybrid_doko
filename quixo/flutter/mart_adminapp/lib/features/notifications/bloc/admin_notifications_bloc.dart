import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/notifications/repository/admin_inbox_remote.dart';

import 'admin_notifications_event.dart';
import 'admin_notifications_state.dart';

class AdminNotificationsBloc
    extends Bloc<AdminNotificationsEvent, AdminNotificationsState> {
  final AdminInboxRemote remote;

  AdminNotificationsBloc(this.remote) : super(const AdminNotificationsInitial()) {
    on<AdminNotificationsLoad>(_onLoad);
  }

  FutureOr<void> _onLoad(
    AdminNotificationsLoad event,
    Emitter<AdminNotificationsState> emit,
  ) async {
    emit(const AdminNotificationsLoading());
    try {
      final items = await remote.fetchNotifications();
      emit(AdminNotificationsLoaded(items));
    } catch (e) {
      emit(AdminNotificationsFailed(e.toString()));
    }
  }
}
