import 'package:equatable/equatable.dart';
import '../data/order_query_model.dart';
import '../data/rider_rating_request_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderFetchRequested extends OrderEvent {
  final OrderQueryModel query;

  const OrderFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class OrderCancelRequested extends OrderEvent {
  final String orderId;

  const OrderCancelRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderReorderRequested extends OrderEvent {
  final String orderId;

  const OrderReorderRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderRiderRatingRequested extends OrderEvent {
  final RiderRatingRequestModel request;

  const OrderRiderRatingRequested(this.request);

  @override
  List<Object?> get props => [request];
}