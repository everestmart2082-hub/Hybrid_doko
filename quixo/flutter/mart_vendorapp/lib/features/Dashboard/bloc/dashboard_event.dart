import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load chart data
class LoadVendorChart extends DashboardEvent {
  final int page;
  final int limit;

  const LoadVendorChart({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}