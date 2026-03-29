import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/products/data/admin_category_model.dart';
import 'package:mart_adminapp/features/products/data/admin_product_model.dart';

abstract class AdminProductState extends Equatable {
  const AdminProductState();
  @override List<Object?> get props => [];
}

class AdminProductInitial extends AdminProductState {}
class AdminProductLoading extends AdminProductState {}

class AdminProductListLoaded extends AdminProductState {
  final List<AdminProductListItem> products;
  const AdminProductListLoaded(this.products);
  @override List<Object?> get props => [products];
}

class AdminProductDetailLoaded extends AdminProductState {
  final AdminProductDetail detail;
  const AdminProductDetailLoaded(this.detail);
  @override List<Object?> get props => [detail];
}

class AdminCategoryLoaded extends AdminProductState {
  final List<CategoryListItem> categories;
  const AdminCategoryLoaded(this.categories);
  @override List<Object?> get props => [categories];
}

class AdminProductActionSuccess extends AdminProductState {
  final String message;
  const AdminProductActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class AdminProductFailed extends AdminProductState {
  final String message;
  const AdminProductFailed(this.message);
  @override List<Object?> get props => [message];
}
