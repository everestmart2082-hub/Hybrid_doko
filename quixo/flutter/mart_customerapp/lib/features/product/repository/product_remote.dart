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

  /// Returns products and whether the server reports another page (`meta.has_more`).
  Future<({List<ProductListItem> products, bool hasMore})> getAllProducts({
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
    String? sortBy,
  }) async {
    final query = {
      'page': page,
      'limit': limit,
      if (minPrice != null) 'min price': minPrice,
      if (maxPrice != null) 'max price': maxPrice,
      if (productCategory != null && productCategory.isNotEmpty)
        'product category': productCategory,
      if (deliveryCategory != null && deliveryCategory.isNotEmpty)
        'delivary category': deliveryCategory,
      if (vendorId != null) 'vender id': vendorId,
      if (searchText != null && searchText.isNotEmpty) 'search text': searchText,
      if (stock != null) 'stock_status': stock ? 'in_stock' : 'out_of_stock',
      if (brand != null && brand.isNotEmpty) 'brand name': brand,
      if (rating != null) 'rating': rating,
      if (sortBy != null && sortBy.isNotEmpty && sortBy != 'default')
        'sort by': sortBy,
    };

    final map = await dio.get("/product/all", query: query);
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    final meta = map['meta'];
    final hasMore = meta is Map && meta['has_more'] == true;
    return (products: list, hasMore: hasMore);
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

    final model = SimpleResponseModel.fromJson(data);
    if (!model.success) {
      throw UnknownFailure(model.message.isNotEmpty ? model.message : 'Review failed');
    }
    return model;
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

    final model = SimpleResponseModel.fromJson(data);
    if (!model.success) {
      throw UnknownFailure(model.message.isNotEmpty ? model.message : 'Rating failed');
    }
    return model;
  }

  void _checkSuccess(Map<String, dynamic> map) {
    if (!(map['success'] as bool)) {
      throw UnknownFailure(
        map['message']?.toString() ?? "Something went wrong",
      );
    }
  }
}
