import 'package:dio/dio.dart';
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
      FormData.fromMap({
        "page": page,
        "limit": limit,
        "search text": searchText,
        "status": status,
        "delivary category": deliveryCategory,
      }),
    );

    final List wrapper = map["message"] ?? [];
    if (wrapper.isNotEmpty && wrapper.length > 1) {
      final List list = wrapper[1];
      return list.map((e) => VendorOrder.fromMap(e)).toList();
    }
    return [];
  }

  Future<void> markOrderPrepared(String orderId) async {
    final map = await dio.post(
      ApiEndpoints.orderPrepared,
      FormData.fromMap({"orders id": orderId}),
    );

    if (!(map["success"] ?? false)) {
      throw Exception(map["message"] ?? "Server error");
    }
  }

  // Future<void> assignRider({
  //   required String ordersId,
  //   required String riderId,
  // }) async {
  //   final map = await dio.post(
  //     '/api/vender/order/assign-rider',
  //     FormData.fromMap({
  //       "orders id": ordersId,
  //       "rider id": riderId,
  //     }),
  //   );
  //   if (!(map["success"] ?? false)) {
  //     throw Exception(map["message"] ?? "Server error");
  //   }
  // }
}
