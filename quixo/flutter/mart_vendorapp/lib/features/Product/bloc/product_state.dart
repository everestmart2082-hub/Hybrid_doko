import '../data/product_model.dart';
import '../data/product_detail_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductListLoaded extends ProductState {
  final List<Product> products;

  ProductListLoaded(this.products);
}

class ProductDetailLoaded extends ProductState {
  final ProductDetail product;

  ProductDetailLoaded(this.product);
}

class ProductFiltersLoaded extends ProductState {
  final List<Map<String, dynamic>> categories;

  ProductFiltersLoaded(this.categories);
}

class ProductSuccess extends ProductState {
  final String message;

  ProductSuccess(this.message);
}

class ProductError extends ProductState {
  final String error;

  ProductError(this.error);
}