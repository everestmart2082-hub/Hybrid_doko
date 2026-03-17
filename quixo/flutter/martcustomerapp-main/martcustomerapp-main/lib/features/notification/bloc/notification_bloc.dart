import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/notification_remote.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRemote notificationRemote;

  NotificationBloc(this.notificationRemote)
      : super(NotificationInitial()) {
    on<NotificationFetchRequested>(_onFetch);
  }

  FutureOr<void> _onFetch(
      NotificationFetchRequested event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications =
          await notificationRemote.getNotifications(event.query);

      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationFailed(e.toString()));
    }
  }
}