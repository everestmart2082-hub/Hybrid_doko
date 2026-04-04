import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/product_remote.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemote repo;

  ProductBloc(this.repo) : super(ProductInitial()) {

    on<GetProducts>((event, emit) async {
      emit(ProductLoading());

      try {
        final products = await repo.getProducts(
          page: event.page,
          limit: event.limit,
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          productCategory: event.productCategory,
          deliveryCategory: event.deliveryCategory,
          searchText: event.searchText,
          brand: event.brand,
          rating: event.rating,
          stock: event.stock,
          sortBy: event.sortBy,
          vendorId: event.vendorId,
          stockFilter: event.stockFilter,
        );

        emit(ProductListLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<GetProductFilters>((event, emit) async {
      emit(ProductLoading());
      try {
        final categories = await repo.getCategories();
        emit(ProductFiltersLoaded(categories));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<GetProductDetail>((event, emit) async {
      emit(ProductLoading());

      try {
        final product = await repo.getProductById(event.id);

        emit(ProductDetailLoaded(product));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<AddProduct>((event, emit) async {
      emit(ProductLoading());

      try {
        await repo.addProduct(event.input, event.files);

        emit(ProductSuccess("Product added"));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<EditProduct>((event, emit) async {
      emit(ProductLoading());

      try {
        await repo.editProduct(event.input, event.files, event.productId);

        emit(ProductSuccess("Product updated"));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<DeleteProduct>((event, emit) async {
      emit(ProductLoading());

      try {
        await repo.deleteProduct(event.id);

        emit(ProductSuccess("Product deleted"));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

  }
}