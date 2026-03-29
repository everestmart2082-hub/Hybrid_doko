import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../data/wishlist_model.dart';
import '../data/wishlist_query_model.dart';
import '../../product/data/simple_response_model.dart';

class WishlistRemote {
  final DioClient dio;

  WishlistRemote({required this.dio});

  /// GET WISHLIST ITEMS
  Future<List<WishlistItemModel>> getWishlist(WishlistQueryModel query) async {
    final response = await dio.get(
      '/api/user/wishlist/get',
      query: query.toJson(),
    );

    final data = response.data ?? response;
    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  /// ADD ITEM
  Future<SimpleResponseModel> addItem(String productId) async {
    final formData = FormData.fromMap({"product id": productId});
    final response = await dio.post(
      '/api/user/wishlist/add',
      formData,
    );
    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  /// REMOVE ITEM
  Future<SimpleResponseModel> removeItem(String wishlistId) async {
    final formData = FormData.fromMap({"wishlist id": wishlistId});
    final response = await dio.post(
      '/api/user/wishlist/remove',
      formData,
    );
    return SimpleResponseModel.fromJson(response.data ?? response);
  }
}