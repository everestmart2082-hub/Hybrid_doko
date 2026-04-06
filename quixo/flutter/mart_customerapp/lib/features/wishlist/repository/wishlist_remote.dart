import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../data/wishlist_model.dart';
import '../data/wishlist_query_model.dart';
import '../../product/data/simple_response_model.dart';

class WishlistRemote {
  final DioClient dio;

  WishlistRemote({required this.dio});

  /// GET WISHLIST ITEMS
  ///
  /// Backend route: `POST /api/user/wishlist/get`
  Future<List<WishlistItemModel>> getWishlist(WishlistQueryModel query) async {
    final response = await dio.post(
      '/user/wishlist/get',
      FormData.fromMap(query.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      final list = data['message'] as List? ?? const [];
      return list
          .map((e) => WishlistItemModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch wishlist');
  }

  /// ADD ITEM
  Future<SimpleResponseModel> addItem(String productId) async {
    final formData = FormData.fromMap({"product id": productId});
    final response = await dio.post(
      '/user/wishlist/add',
      formData,
    );
    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }

  /// REMOVE ITEM
  Future<SimpleResponseModel> removeItem(String wishlistId) async {
    final formData = FormData.fromMap({"wishlist id": wishlistId});
    final response = await dio.post(
      '/user/wishlist/remove',
      formData,
    );
    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }
}
