import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/dashboard_remote.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class RiderDashboardBloc extends Bloc<RiderDashboardEvent, RiderDashboardState> {
  final RiderDashboardRemote remote;

  RiderDashboardBloc(this.remote) : super(RiderDashboardInitial()) {
    on<RiderDashboardFetchRequested>(_onFetch);
  }

  FutureOr<void> _onFetch(
      RiderDashboardFetchRequested event, Emitter<RiderDashboardState> emit) async {
    emit(RiderDashboardLoading());
    try {
      final dashboard = await remote.fetchDashboard();
      emit(RiderDashboardLoaded(dashboard));
    } catch (e) {
      emit(RiderDashboardFailure(e.toString()));
    }
  }
}