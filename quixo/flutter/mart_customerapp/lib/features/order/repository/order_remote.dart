
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
      '/user/order/all',
      query: query.toMap(),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data["success"] == true) {
      final list = data["message"] as List? ?? const [];
      final flattened = <Map<String, dynamic>>[];
      for (final entry in list) {
        if (entry is Map<String, dynamic> && entry["items"] is List) {
          for (final child in (entry["items"] as List)) {
            if (child is Map) {
              flattened.add(child.cast<String, dynamic>());
            }
          }
        } else if (entry is Map) {
          flattened.add(entry.cast<String, dynamic>());
        }
      }
      return flattened.map(OrderModel.fromJson).toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  /// CANCEL ORDER
  Future<SimpleResponseModel> cancelOrder(String orderId) async {
    final formData = FormData.fromMap({"order id": orderId});
    final response = await dio.post(
      '/user/order/cancel',
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
      '/user/orders/reorder',
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
      '/user/rider/rating',
      formData,
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    return SimpleResponseModel.fromJson(data);
  }
}
