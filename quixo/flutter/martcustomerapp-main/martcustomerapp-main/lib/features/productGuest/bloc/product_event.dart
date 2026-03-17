import 'package:equatable/equatable.dart';

import '../data/product_query_model.dart';

abstract class ProductGuestEvent extends Equatable {
  const ProductGuestEvent();
  @override
  List<Object?> get props => [];
}

class ProductFetchById extends ProductGuestEvent {
  final String id;
  const ProductFetchById(this.id);

  @override
  List<Object?> get props => [id];
}

class ProductFetchAll extends ProductGuestEvent {
  final int page;
  final int limit;
  const ProductFetchAll({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class ProductFetchRecommended extends ProductGuestEvent {}

class ProductFetchRequested extends ProductGuestEvent {
  final ProductQuery query;

  const ProductFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to fetch a single product by ID
class ProductFetchByIdRequested extends ProductGuestEvent {
  final String productId;

  const ProductFetchByIdRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to fetch recommended products (used in product detail page)
class ProductFetchRecommendedRequested extends ProductGuestEvent {}