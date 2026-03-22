import 'package:equatable/equatable.dart';

abstract class RiderDashboardEvent extends Equatable {
  const RiderDashboardEvent();
  @override
  List<Object?> get props => [];
}

class RiderDashboardFetchRequested extends RiderDashboardEvent {
}