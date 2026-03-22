import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/notification_remote.dart';
import 'notification_event.dart';
import 'notification_state.dart';


class RiderNotificationBloc
    extends Bloc<RiderNotificationEvent, RiderNotificationState> {
  final RiderNotificationRemote remote;

  RiderNotificationBloc(this.remote) : super(RiderNotificationInitial()) {
    on<RiderNotificationFetchRequested>(_onFetch);
  }

  FutureOr<void> _onFetch(
      RiderNotificationFetchRequested event,
      Emitter<RiderNotificationState> emit) async {
    emit(RiderNotificationLoading());

    try {
      final notifications = await remote.getNotifications(
        page: event.page,
        limit: event.limit,
      );

      emit(RiderNotificationLoaded(notifications));
    } catch (e) {
      emit(RiderNotificationFailure(e.toString()));
    }
  }
}