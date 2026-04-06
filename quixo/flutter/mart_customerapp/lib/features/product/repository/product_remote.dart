import 'package:dio/dio.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';
import 'package:quickmartcustomer/features/product/data/review_model.dart';
import '../data/product_list_item_model.dart';
import '../data/product_model.dart';
import '../data/rating_request_model.dart';
import '../data/simple_response_model.dart';

class ProductRemote {
  final DioClient dio;

  ProductRemote({required this.dio});

  Future<ProductModel> getProductById(String id) async {
    final map = await dio.get("/product/id", query: {"product id": id});
    _checkSuccess(map);
    return ProductModel.fromMap(map['message'] as Map<String, dynamic>);
  }

  Future<List<ProductListItem>> getAllProducts({
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? productCategory,
    String? deliveryCategory,
    String? vendorId,
    String? searchText,
    bool? stock,
    String? brand,
    double? rating,
  }) async {
    final query = {
      'page': page,
      'limit': limit,
      if (minPrice != null) 'min price': minPrice,
      if (maxPrice != null) 'max price': maxPrice,
      if (productCategory != null) 'product category': productCategory,
      if (deliveryCategory != null) 'delivary category': deliveryCategory,
      if (vendorId != null) 'vender id': vendorId,
      if (searchText != null) 'search text': searchText,
      if (stock != null) 'stock_status': stock ? 'in_stock' : 'out_of_stock',
      if (brand != null) 'brand name': brand,
      if (rating != null) 'rating': rating,
    };

    final map = await dio.get("/product/all", query: query);
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final map = await dio.get("/category/all");
    _checkSuccess(map);
    final raw = map["data"] ?? map["message"];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  Future<List<ProductListItem>> getRecommendedProducts() async {
    final map = await dio.get("/product/recommended");
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<SimpleResponseModel> addReview(ReviewRequestModel review) async {
    final formData = FormData.fromMap({
      "product id": review.productId,
      "message": review.message,
    });

    final response = await dio.post(ApiEndpoints.addReview, formData);

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map
              ? response.cast<String, dynamic>()
              : <String, dynamic>{});

    return SimpleResponseModel.fromJson(data);
  }

  Future<SimpleResponseModel> addRating(RatingRequestModel rating) async {
    // Backend parses rating using `strconv.Atoi`, so ensure it's an integer string.
    final formData = FormData.fromMap({
      "product id": rating.productId,
      "rating": rating.rating.toInt().toString(),
    });

    final response = await dio.post(ApiEndpoints.addRating, formData);

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map
              ? response.cast<String, dynamic>()
              : <String, dynamic>{});

    return SimpleResponseModel.fromJson(data);
  }

  void _checkSuccess(Map<String, dynamic> map) {
    if (!(map['success'] as bool)) {
      throw UnknownFailure(
        map['message']?.toString() ?? "Something went wrong",
      );
    }
  }
}
