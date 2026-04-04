import 'package:dio/dio.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/network/shared_pref.dart';

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
    String stockFilter = "",
  }) async {
    final store = SharedPreferencesProvider();
    final storedVid = await store.getKey(prefs.vendorId.name);
    final effectiveVendorId =
        vendorId != "all" ? vendorId : (storedVid ?? "");

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
        if (effectiveVendorId.isNotEmpty) "vender id": effectiveVendorId,
        if (stockFilter.isNotEmpty) "stock_status": stockFilter,
      },
    );

    final List data = res["message"] ?? [];
    return data.map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await dio.get("/api/category/all");
    final raw = res["data"] ?? res["message"];
    if (raw is List) {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  Future<ProductDetail> getProductById(String id) async {
    final res = await dio.get(
      ApiEndpoints.productById,
      query: {"product id": id},
    );

    final msg = res["message"];
    if (msg is! Map) {
      throw StateError('Invalid product response');
    }
    return ProductDetail.fromMap(Map<String, dynamic>.from(msg));
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