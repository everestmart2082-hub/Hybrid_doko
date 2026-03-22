import 'package:equatable/equatable.dart';

import '../data/dashboard_model.dart';

abstract class RiderDashboardState extends Equatable {
  const RiderDashboardState();
  @override
  List<Object?> get props => [];
}

class RiderDashboardInitial extends RiderDashboardState {}
class RiderDashboardLoading extends RiderDashboardState {}
class RiderDashboardLoaded extends RiderDashboardState {
  final RiderDashboardModel dashboard;
  const RiderDashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}
class RiderDashboardFailure extends RiderDashboardState {
  final String message;
  const RiderDashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}