import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/rating_request_model.dart';
import '../data/review_model.dart';
import '../repository/product_remote.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemote productRemote;

  ProductBloc(this.productRemote) : super(ProductInitial()) {
    on<ProductFetchById>(_onFetchById);
    on<ProductFetchAll>(_onFetchAll);
    on<ProductFetchRecommended>(_onFetchRecommended);
    on<ProductFetchRequested>(_onFetchProducts);
    on<ProductFetchByIdRequested>(_onFetchProductById);
    on<ProductFetchRecommendedRequested>(_onFetchRecommendedRequested);
    on<ProductAddReviewRequested>(_onAddReview);
    on<ProductAddRatingRequested>(_onAddRating);
    on<ProductSubmitReviewRequested>(_onSubmitReview);
  }

  FutureOr<void> _onFetchProducts(
      ProductFetchRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final query = event.query;
      final sortKey = query.sort == null || query.sort == 'default'
          ? null
          : query.sort;
      final res = await productRemote.getAllProducts(
        page: query.page,
        limit: query.limit,
        minPrice: query.minPrice,
        maxPrice: query.maxPrice,
        productCategory: query.category,
        deliveryCategory: query.deliveryCategory,
        vendorId: query.vendorId,
        searchText: query.search,
        stock: query.inStock,
        brand: query.brand,
        rating: query.rating,
        sortBy: sortKey,
      );
      emit(ProductListLoaded(res.products, hasMore: res.hasMore));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchProductById(
      ProductFetchByIdRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRemote.getProductById(event.productId);
      emit(ProductLoaded( product));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchRecommendedRequested(
      ProductFetchRecommendedRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final recommended = await productRemote.getRecommendedProducts();
      emit(ProductRecommendedLoaded(recommendedProducts: recommended));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchById(ProductFetchById event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRemote.getProductById(event.id);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchAll(ProductFetchAll event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final res = await productRemote.getAllProducts(
        page: event.page,
        limit: event.limit,
      );
      emit(ProductListLoaded(res.products, hasMore: res.hasMore));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onFetchRecommended(ProductFetchRecommended event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productRemote.getRecommendedProducts();
      emit(ProductListLoaded(products, hasMore: false));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onAddReview(
      ProductAddReviewRequested event,
      Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final response = await productRemote.addReview(event.review);
      emit(ProductActionSuccess(response.message));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onAddRating(
      ProductAddRatingRequested event,
      Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final response = await productRemote.addRating(event.rating);
      emit(ProductActionSuccess(response.message));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }

  FutureOr<void> _onSubmitReview(
    ProductSubmitReviewRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await productRemote.addReview(
        ReviewRequestModel(productId: event.productId, message: event.message),
      );
      await productRemote.addRating(
        RatingRequestModel(
          productId: event.productId,
          rating: event.ratingStars.toDouble(),
        ),
      );
      final product = await productRemote.getProductById(event.productId);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductFailed(e.toString()));
    }
  }
}