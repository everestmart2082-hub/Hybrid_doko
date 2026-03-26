import 'package:equatable/equatable.dart';
import '../data/product_list_item_model.dart';
import '../data/product_model.dart';

abstract class ProductGuestState extends Equatable {
  const ProductGuestState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductGuestState {}

class ProductLoading extends ProductGuestState {}

class ProductLoaded extends ProductGuestState {
  final ProductModel product;
  const ProductLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductListLoaded extends ProductGuestState {
  final List<ProductListItem> products;
  const ProductListLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductFailed extends ProductGuestState {
  final String message;
  const ProductFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductRecommendedLoaded extends ProductGuestState {
  final List<ProductListItem> recommendedProducts;

  const ProductRecommendedLoaded({required this.recommendedProducts});

  @override
  List<Object?> get props => [recommendedProducts];
}