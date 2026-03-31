
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../product/data/simple_response_model.dart';
import '../data/cart_item_model.dart';
import '../data/cart_model.dart';
import '../data/cart_query_model.dart';

class CartRemote {
  final DioClient dio;

  CartRemote({required this.dio});

  Future<List<CartItemModel>> getCartItems(CartQueryModel query) async {
    // Controller doesn't actually paginate based on query payload for now, but we send it as query params just in case
    final map = await dio.post(
      '/api/user/cart/get',
      FormData.fromMap(query.toJson()),
    );
    
    if (map["success"] == true) {
      return (map["message"] as List)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(map["message"]?.toString() ?? "Failed");
    }
  }

  /// ADD TO CART
  Future<SimpleResponseModel> addToCart(CartAddRequestModel request) async {
    final map = await dio.post('/api/user/cart/add', request.toFormData());
    return SimpleResponseModel.fromJson(map as Map<String, dynamic>);
  }

  /// REMOVE FROM CART
  Future<SimpleResponseModel> removeFromCart(String cartId) async {
    final formData = FormData.fromMap({"cart id": cartId});
    final map = await dio.delete('/api/user/cart/remove', formData);
    return SimpleResponseModel.fromJson(map as Map<String, dynamic>);
  }
}
