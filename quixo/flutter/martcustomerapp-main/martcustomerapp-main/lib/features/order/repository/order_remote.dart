import 'package:quickmartcustomer/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/order_model.dart';
import '../data/order_query_model.dart';
import '../../product/data/simple_response_model.dart';
import '../data/rider_rating_request_model.dart';

class OrderRemote {
  final DioClient dio;

  OrderRemote({required this.dio});

  /// GET ALL ORDERS
  Future<List<OrderModel>> getAllOrders(
      OrderQueryModel query) async {
    final response = await dio.get(
      ApiEndpoints.getOrder,
      query: query.toQuery(),
    );

    final data = response.data;

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  /// CANCEL ORDER
  Future<SimpleResponseModel> cancelOrder(
      String orderId) async {
    final response = await dio.delete(
      ApiEndpoints.cancelOrder,
      {"order_id": orderId},
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  /// REORDER
  Future<SimpleResponseModel> reorder(
      String orderId) async {
    final response = await dio.delete(
      ApiEndpoints.reorder,
      {"order_id": orderId},
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  /// RATE RIDER
  Future<SimpleResponseModel> rateRider(
      RiderRatingRequestModel request) async {
    final response = await dio.post(
      '/user/rider/rating',
      request.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }
}