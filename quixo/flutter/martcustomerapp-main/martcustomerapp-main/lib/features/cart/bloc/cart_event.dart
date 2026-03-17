import 'package:equatable/equatable.dart';

import '../data/cart_model.dart';
import '../data/cart_query_model.dart';
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}


class CartFetchRequested extends CartEvent {
  final CartQueryModel query;

  const CartFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class CartAddRequested extends CartEvent {
  final CartAddRequestModel request;

  const CartAddRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class CartRemoveRequested extends CartEvent {
  final String cartId;

  const CartRemoveRequested(this.cartId);

  @override
  List<Object?> get props => [cartId];
}