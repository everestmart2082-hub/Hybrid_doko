import 'package:equatable/equatable.dart';

abstract class RiderNotificationEvent extends Equatable {
  const RiderNotificationEvent();

  @override
  List<Object?> get props => [];
}

class RiderNotificationFetchRequested extends RiderNotificationEvent {
  final int page;
  final int limit;

  const RiderNotificationFetchRequested({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}