import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/products/data/admin_category_model.dart';

abstract class AdminProductEvent extends Equatable {
  const AdminProductEvent();
  @override List<Object?> get props => [];
}

// ── Products ──────────────────────────────────────────────────────────────────
class AdminProductLoad extends AdminProductEvent {}

class AdminProductLoadById extends AdminProductEvent {
  final String productId;
  const AdminProductLoadById(this.productId);
  @override List<Object?> get props => [productId];
}

class AdminProductApprove extends AdminProductEvent {
  final String productId; final bool approved;
  const AdminProductApprove({required this.productId, required this.approved});
  @override List<Object?> get props => [productId, approved];
}

class AdminProductHide extends AdminProductEvent {
  final String productId; final bool hide;
  const AdminProductHide({required this.productId, required this.hide});
  @override List<Object?> get props => [productId, hide];
}

// ── Categories ────────────────────────────────────────────────────────────────
class AdminCategoryLoad extends AdminProductEvent {}

class AdminCategoryAdd extends AdminProductEvent {
  final AdminCategoryRequest req;
  const AdminCategoryAdd(this.req);
  @override List<Object?> get props => [req];
}

class AdminCategoryEdit extends AdminProductEvent {
  final String categoryId; final AdminCategoryRequest req;
  const AdminCategoryEdit({required this.categoryId, required this.req});
  @override List<Object?> get props => [categoryId, req];
}

class AdminCategoryHide extends AdminProductEvent {
  final String categoryId; final bool hidden;
  const AdminCategoryHide({required this.categoryId, required this.hidden});
  @override List<Object?> get props => [categoryId, hidden];
}
