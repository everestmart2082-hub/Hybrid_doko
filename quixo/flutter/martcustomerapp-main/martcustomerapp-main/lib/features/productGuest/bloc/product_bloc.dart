import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/product_remote.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductGuestBloc extends Bloc<ProductGuestEvent, ProductGuestState> {
  final ProductGuestRemote productRemote;

  ProductGuestBloc(this.productRemote) : super(ProductInitial()) {
    on<ProductFetchById>(_onFetchById);
    on<ProductFetchAll>(_onFetchAll);
    on<ProductFetchRecommended>(_onFetchRecommended);
     on<ProductFetchRequested>(_onFetchProducts);
    on<ProductFetchByIdRequested>(_onFetchProductById);
    on<ProductFetchRecommendedRequested>(_onFetchRecommendedRequested);
  }

   FutureOr<void> _onFetchProducts(
      ProductFetchRequested event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final query = event.query;
      final products = await productRemote.getAllProducts(minPrice: query.minPrice, maxPrice: query.maxPrice, productCategory: query.category, deliveryCategory: query.deliveryCategory, vendorId: query.vendorId, searchText: query.search, stock: query.inStock, brand: query.brand, rating: query.rating);
      emit(ProductListLoaded(products));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchProductById(
      ProductFetchByIdRequested event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRemote.getProductById(event.productId);
      emit(ProductLoaded( product));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchRecommendedRequested(
      ProductFetchRecommendedRequested event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final recommended = await productRemote.getRecommendedProducts();
      emit(ProductRecommendedLoaded(recommendedProducts: recommended));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchById(ProductFetchById event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRemote.getProductById(event.id);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchAll(ProductFetchAll event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productRemote.getAllProducts(page: event.page, limit: event.limit);
      emit(ProductListLoaded(products));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchRecommended(ProductFetchRecommended event, Emitter<ProductGuestState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productRemote.getRecommendedProducts();
      emit(ProductListLoaded(products));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }
}