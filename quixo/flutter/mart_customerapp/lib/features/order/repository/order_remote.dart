
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

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data["success"] == true) {
      final list = data["message"] as List? ?? const [];
      return list
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

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }

  /// REORDER
  Future<SimpleResponseModel> reorder(String orderId) async {
    final formData = FormData.fromMap({"order id": orderId});
    final response = await dio.post(
      '/api/user/orders/reorder',
      formData,
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }

  /// RATE RIDER
  Future<SimpleResponseModel> rateRider(RiderRatingRequestModel request) async {
    // Backend uses `c.PostForm("rider id")` + `c.PostForm("rating")` (strconv.Atoi).
    final formData = FormData.fromMap({
      "rider id": request.riderId,
      "rating": request.rating.toInt().toString(),
    });

    final response = await dio.post(
      '/api/user/rider/rating',
      formData,
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    return SimpleResponseModel.fromJson(data);
  }
}
