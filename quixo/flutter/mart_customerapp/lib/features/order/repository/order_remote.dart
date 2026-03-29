
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../data/order_model.dart';
import '../data/order_query_model.dart';
import '../../product/data/simple_response_model.dart';
import '../data/rider_rating_request_model.dart';

class OrderRemote {
  final DioClient dio;

  OrderRemote({required this.dio});

  /// GET ALL ORDERS
  Future<List<OrderModel>> getAllOrders(OrderQueryModel query) async {
    final response = await dio.get(
      '/api/user/order/all',
      query: query.toMap(),
    );

    final data = response.data ?? response; // Depending on dio interceptor config

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  /// CANCEL ORDER
  Future<SimpleResponseModel> cancelOrder(String orderId) async {
    final formData = FormData.fromMap({"order id": orderId});
    final response = await dio.post(
      '/api/user/order/cancel',
      formData,
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  /// REORDER
  Future<SimpleResponseModel> reorder(String orderId) async {
    final formData = FormData.fromMap({"order id": orderId});
    final response = await dio.post(
      '/api/user/orders/reorder',
      formData,
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  /// RATE RIDER
  Future<SimpleResponseModel> rateRider(RiderRatingRequestModel request) async {
    final response = await dio.post(
      '/api/user/rider/rating',
      request.toJson(), // assuming rating uses standard json based on go server standard elsewhere
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }
}