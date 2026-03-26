import 'package:equatable/equatable.dart';
import '../data/checkout_request_model.dart';
import '../data/payment_query_model.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutRequested extends PaymentEvent {
  final CheckoutRequestModel request;

  const CheckoutRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class PaymentStatusRequested extends PaymentEvent {
  final PaymentQueryModel query;

  const PaymentStatusRequested(this.query);

  @override
  List<Object?> get props => [query];
}