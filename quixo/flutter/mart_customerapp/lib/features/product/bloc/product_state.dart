import 'package:equatable/equatable.dart';
import '../data/product_list_item_model.dart';
import '../data/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final ProductModel product;
  const ProductLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductListLoaded extends ProductState {
  final List<ProductListItem> products;
  const ProductListLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductFailed extends ProductState {
  final String message;
  const ProductFailed(this.message);
  @override
  List<Object?> get props => [message];
}


class ProductRecommendedLoaded extends ProductState {
  final List<ProductListItem> recommendedProducts;

  const ProductRecommendedLoaded({required this.recommendedProducts});

  @override
  List<Object?> get props => [recommendedProducts];
}

class ProductActionSuccess extends ProductState {
  final String message;

  const ProductActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}