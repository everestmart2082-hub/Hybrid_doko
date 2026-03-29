import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Dashboard/repository/dashboard_remote.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemote repo;

  DashboardBloc(this.repo) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  FutureOr<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    try {
      final stats = await repo.getDashboardStats();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}