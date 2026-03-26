import '../../../core/network/dio_client.dart';
import '../data/wishlist_model.dart';
import '../data/wishlist_query_model.dart';
import '../../product/data/simple_response_model.dart';

class WishlistRemote {
  final DioClient dio;

  WishlistRemote({required this.dio});

  /// GET WISHLIST ITEMS
  Future<List<WishlistItemModel>> getWishlist(WishlistQueryModel query) async {
    final response = await dio.post(
      '/user/wishlist',
      query.toJson(),
    );

    final data = response.data;
    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => WishlistItemModel.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  /// ADD ITEM
  Future<SimpleResponseModel> addItem(String productId) async {
    final response = await dio.post(
      '/user/wishlist/item',
      {"product_id": productId},
    );
    return SimpleResponseModel.fromJson(response.data);
  }

  /// REMOVE ITEM
  Future<SimpleResponseModel> removeItem(String productId) async {
    final response = await dio.delete(
      '/user/wishlist/item',
      {"product_id": productId},
    );
    return SimpleResponseModel.fromJson(response.data);
  }
}