import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/products/repository/admin_category_remote.dart';
import 'package:mart_adminapp/features/products/repository/admin_product_remote.dart';
import 'admin_product_event.dart';
import 'admin_product_state.dart';

class AdminProductBloc extends Bloc<AdminProductEvent, AdminProductState> {
  final AdminProductRemote productRemote;
  final AdminCategoryRemote categoryRemote;

  AdminProductBloc({required this.productRemote, required this.categoryRemote})
      : super(AdminProductInitial()) {
    on<AdminProductLoad>(_onLoad);
    on<AdminProductLoadById>(_onLoadById);
    on<AdminProductApprove>(_onApprove);
    on<AdminProductHide>(_onHide);
    on<AdminCategoryLoad>(_onCategoryLoad);
    on<AdminCategoryAdd>(_onCategoryAdd);
    on<AdminCategoryEdit>(_onCategoryEdit);
    on<AdminCategoryHide>(_onCategoryHide);
  }

  FutureOr<void> _onLoad(AdminProductLoad _, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      emit(AdminProductListLoaded(await productRemote.getAllProducts()));
    } catch (e) {
      emit(AdminProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onLoadById(AdminProductLoadById e, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      emit(AdminProductDetailLoaded(await productRemote.getProductById(e.productId)));
    } catch (ex) {
      emit(AdminProductFailed(ex.toString()));
    }
  }

  FutureOr<void> _withReload(Future<void> Function() action,
      Emitter<AdminProductState> emit, {String success = 'Done'}) async {
    emit(AdminProductLoading());
    try {
      await action();
      emit(AdminProductActionSuccess(success));
      emit(AdminProductListLoaded(await productRemote.getAllProducts()));
    } catch (e) {
      emit(AdminProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onApprove(AdminProductApprove e, Emitter<AdminProductState> emit) =>
      _withReload(() => productRemote.approveProduct(e.productId, e.approved), emit,
          success: 'Product approval updated.');

  FutureOr<void> _onHide(AdminProductHide e, Emitter<AdminProductState> emit) =>
      _withReload(() => productRemote.hideProduct(e.productId, e.hide), emit,
          success: 'Product visibility updated.');

  FutureOr<void> _onCategoryLoad(AdminCategoryLoad _, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      emit(AdminCategoryLoaded(await categoryRemote.getAllCategories()));
    } catch (e) {
      emit(AdminProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onCategoryAdd(AdminCategoryAdd e, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      await categoryRemote.addCategory(e.req);
      emit(const AdminProductActionSuccess('Category added.'));
    } catch (ex) {
      emit(AdminProductFailed(ex.toString()));
    }
  }

  FutureOr<void> _onCategoryEdit(AdminCategoryEdit e, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      await categoryRemote.editCategory(e.categoryId, e.req);
      emit(const AdminProductActionSuccess('Category updated.'));
    } catch (ex) {
      emit(AdminProductFailed(ex.toString()));
    }
  }

  FutureOr<void> _onCategoryHide(AdminCategoryHide e, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      await categoryRemote.hideCategory(e.categoryId, e.hidden);
      emit(const AdminProductActionSuccess('Category visibility updated.'));
    } catch (ex) {
      emit(AdminProductFailed(ex.toString()));
    }
  }
}
