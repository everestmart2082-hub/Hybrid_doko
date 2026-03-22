import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {

  const NotificationEvent();

  @override
  List<Object?> get props => [];

}

class LoadNotifications extends NotificationEvent {

  final int page;
  final int limit;

  const LoadNotifications({
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [page, limit];

}