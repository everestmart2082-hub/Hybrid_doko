import 'package:quickmartvender/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/product_model.dart';
import '../data/product_detail_model.dart';
import '../data/product_input_model.dart';

class ProductRemote {
  final DioClient dio;

  ProductRemote({required this.dio});

  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    final res = await dio.get(
      ApiEndpoints.products,
      query: {
        "page": page,
        "limit": limit,
      },
    );

    final List data = res.data["message"];

    return data.map((e) => Product.fromMap(e)).toList();
  }

  Future<ProductDetail> getProductById(String id) async {
    final res = await dio.get(
      ApiEndpoints.productById,
      query: {"product id": id},
    );

    return ProductDetail.fromMap(res.data["message"]);
  }

  Future<void> addProduct(ProductInput input) async {
    await dio.post(
      ApiEndpoints.addProduct,
      input.toMap(),
    );
  }

  Future<void> editProduct(ProductInput input) async {
    await dio.post(
      ApiEndpoints.editProduct,
      input.toMap(),
    );
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete(
      ApiEndpoints.deleteProduct,
      {"product id": id},
    );
  }
}