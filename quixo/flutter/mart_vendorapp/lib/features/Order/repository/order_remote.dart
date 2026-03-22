
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/order_model.dart';

class OrderRemote {
  final DioClient dio;

  OrderRemote({required this.dio});

  Future<List<VendorOrder>> getAllOrders({
    int page = 1,
    int limit = 10,
    String searchText = "",
    String status = "",
    String deliveryCategory = "",
  }) async {
    final map = await dio.post(
      ApiEndpoints.order,
      {
        "page": page,
        "limit": limit,
        "search text": searchText,
        "status": status,
        "delivary category": deliveryCategory,
      },
    );

    final List list = map["message"];
    return list.map((e) => VendorOrder.fromMap(e)).toList();
  }

  Future<void> markOrderPrepared(String orderId) async {
    final map = await dio.post(
      ApiEndpoints.orderPrepared,
      {"order id": orderId},
    );

    if (!(map["success"] ?? false)) {
      throw Exception(map["message"] ?? "Server error");
    }
  }
}