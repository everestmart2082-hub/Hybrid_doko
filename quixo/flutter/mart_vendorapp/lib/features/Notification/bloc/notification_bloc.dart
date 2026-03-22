import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/failures/failures.dart';

import '../repository/notification_remote.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  final NotificationRemote remote;

  NotificationBloc(this.remote) : super(NotificationInitial()) {

    on<LoadNotifications>(_onLoadNotifications);

  }

  FutureOr<void> _onLoadNotifications(
      LoadNotifications event,
      Emitter<NotificationState> emit,
  ) async {

    emit(NotificationLoading());

    try {

      final notifications = await remote.getNotifications(
        event.page,
        event.limit,
      );

      emit(NotificationLoaded(notifications: notifications));

    } catch (e) {

      emit(_mapError(e));

    }

  }

  NotificationFailed _mapError(Object e) {

    if (e is Failure) {
      return NotificationFailed(message: e.message);
    }

    return const NotificationFailed(
      message: "Something went wrong",
    );

  }

}