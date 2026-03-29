import 'package:dio/dio.dart';
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
    double? minPrice,
    double? maxPrice,
    String productCategory = "",
    String deliveryCategory = "",
    String searchText = "",
    String brand = "",
    int? rating,
    int? stock,
    String sortBy = "default",
    String vendorId = "all",
  }) async {
    final res = await dio.get(
      ApiEndpoints.products,
      query: {
        "page": page,
        "limit": limit,
        if (minPrice != null) "min price": minPrice,
        if (maxPrice != null) "max price": maxPrice,
        if (productCategory.isNotEmpty) "product category": productCategory,
        if (deliveryCategory.isNotEmpty) "delivary category": deliveryCategory,
        if (searchText.isNotEmpty) "search text": searchText,
        if (brand.isNotEmpty) "brand name": brand,
        if (rating != null) "rating": rating,
        if (stock != null) "stock": stock,
        if (sortBy != "default") "sort by": sortBy,
        if (vendorId != "all") "vendor id": vendorId,
      },
    );

    final List data = res["message"] ?? [];
    return data.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await dio.get("/api/category/all");
    if (res["message"] is List) {
      return List<Map<String, dynamic>>.from(res["message"]);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getVendors() async {
    final res = await dio.get("/api/vender/all");
    if (res["message"] is List) {
      return List<Map<String, dynamic>>.from(res["message"]);
    }
    return [];
  }

  Future<ProductDetail> getProductById(String id) async {
    final res = await dio.get(
      ApiEndpoints.productById,
      query: {"product id": id},
    );

    return ProductDetail.fromMap(res["message"]);
  }

  Future<void> addProduct(ProductInput input, List<MultipartFile> files) async {
    FormData formData = FormData.fromMap({
      ...input.toMap(),
      "Photos": files
    });

    await dio.post(
      ApiEndpoints.addProduct,
      formData,
    );
  }

  Future<void> editProduct(ProductInput input, List<MultipartFile> files, String productId) async {
    FormData formData = FormData.fromMap({
      ...input.toMap(),
      "product id": productId,
      "Photos": files
    });

    await dio.post(
      ApiEndpoints.editProduct,
      formData,
    );
  }

  Future<void> deleteProduct(String id) async {
    final encodedParam = Uri.encodeComponent("product id");
    await dio.delete(
      "${ApiEndpoints.deleteProduct}?$encodedParam=$id",
      {},
    );
  }
}