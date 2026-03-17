import 'package:equatable/equatable.dart';
import '../data/notification_query_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationFetchRequested extends NotificationEvent {
  final NotificationQueryModel query;

  const NotificationFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}