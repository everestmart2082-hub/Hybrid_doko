import 'package:quickmartcustomer/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../../product/data/simple_response_model.dart';
import '../data/cart_item_model.dart';
import '../data/cart_model.dart';
import '../data/cart_query_model.dart';

class CartRemote {
  final DioClient dio;

  CartRemote({required this.dio});

  Future<List<CartItemModel>> getCartItems(CartQueryModel query) async {
    final response = await dio.post(
      '/user/cart/get',
      query.toJson(),
    );

    final data = response.data;
    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }


  /// ADD TO CART
  Future<SimpleResponseModel> addToCart(
      CartAddRequestModel request) async {
    final response = await dio.post(
      ApiEndpoints.addCart,
      request.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  /// REMOVE FROM CART
  Future<SimpleResponseModel> removeFromCart(
      String cartId) async {
    final response = await dio.delete(
      ApiEndpoints.removeCart,
      {
        "cart_id": cartId,
      },
    );

    return SimpleResponseModel.fromJson(response.data);
  }
}