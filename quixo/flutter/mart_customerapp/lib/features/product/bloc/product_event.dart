import 'package:equatable/equatable.dart';

import '../../product/data/product_query.dart';
import '../data/review_model.dart';
import '../data/rating_request_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductFetchById extends ProductEvent {
  final String id;
  const ProductFetchById(this.id);

  @override
  List<Object?> get props => [id];
}

class ProductFetchAll extends ProductEvent {
  final int page;
  final int limit;
  const ProductFetchAll({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class ProductFetchRecommended extends ProductEvent {}


class ProductFetchRequested extends ProductEvent {
  final ProductQuery query;

  const ProductFetchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to fetch a single product by ID
class ProductFetchByIdRequested extends ProductEvent {
  final String productId;

  const ProductFetchByIdRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to fetch recommended products (used in product detail page)
class ProductFetchRecommendedRequested extends ProductEvent {}

class ProductAddReviewRequested extends ProductEvent {
  final ReviewRequestModel review;

  const ProductAddReviewRequested(this.review);

  @override
  List<Object?> get props => [review];
}

class ProductAddRatingRequested extends ProductEvent {
  final RatingRequestModel rating;

  const ProductAddRatingRequested(this.rating);

  @override
  List<Object?> get props => [rating];
}

/// Submits review text and star rating in one flow, then reloads the product.
class ProductSubmitReviewRequested extends ProductEvent {
  final String productId;
  final String message;
  final int ratingStars;

  const ProductSubmitReviewRequested({
    required this.productId,
    required this.message,
    required this.ratingStars,
  });

  @override
  List<Object?> get props => [productId, message, ratingStars];
}