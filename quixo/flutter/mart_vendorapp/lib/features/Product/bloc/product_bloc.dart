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
        final products =
            await repo.getProducts(page: event.page, limit: event.limit);

        emit(ProductListLoaded(products));
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
        await repo.addProduct(event.input);

        emit(ProductSuccess("Product added"));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<EditProduct>((event, emit) async {
      emit(ProductLoading());

      try {
        await repo.editProduct(event.input);

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