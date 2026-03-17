import 'package:equatable/equatable.dart';
import '../data/wishlist_query_model.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class WishlistFetchRequested extends WishlistEvent {
  final WishlistQueryModel query;

  const WishlistFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class WishlistAddItemRequested extends WishlistEvent {
  final String productId;

  const WishlistAddItemRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class WishlistRemoveItemRequested extends WishlistEvent {
  final String productId;

  const WishlistRemoveItemRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}