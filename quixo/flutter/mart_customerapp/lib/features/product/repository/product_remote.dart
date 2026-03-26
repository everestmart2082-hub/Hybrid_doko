import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';
import 'package:quickmartcustomer/features/product/data/review_model.dart';
import '../data/product_list_item_model.dart';
import '../data/product_model.dart';
import '../../../core/network/dio_client.dart';
import '../data/rating_request_model.dart';
import '../data/simple_response_model.dart';

class ProductRemote {
  final DioClient dio;

  ProductRemote({required this.dio});

  Future<ProductModel> getProductById(String id) async {
    final map = await dio.get("${ApiEndpoints.baseUrl}/product/$id");
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
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (productCategory != null) 'productCategory': productCategory,
      if (deliveryCategory != null) 'deliveryCategory': deliveryCategory,
      if (vendorId != null) 'vendorId': vendorId,
      if (searchText != null) 'searchText': searchText,
      if (stock != null) 'stock': stock,
      if (brand != null) 'brand': brand,
      if (rating != null) 'rating': rating,
    };

    final map = await dio.get("${ApiEndpoints.baseUrl}/product/all", query: query);
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<ProductListItem>> getRecommendedProducts() async {
    final map = await dio.get("${ApiEndpoints.baseUrl}/product/recommended");
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<SimpleResponseModel> addReview(ReviewRequestModel review) async {
    final response = await dio.post(
      ApiEndpoints.addReview,
      review.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  Future<SimpleResponseModel> addRating(RatingRequestModel rating) async {
    final response = await dio.post(
      ApiEndpoints.addRating,
      rating.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  void _checkSuccess(Map<String, dynamic> map) {
    if (!(map['success'] as bool)) {
      throw UnknownFailure( map['message'] ?? "Something went wrong");
    }
  }
}