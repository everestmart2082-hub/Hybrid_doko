import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_order_model.dart';

class AdminOrdersRemote {
  final DioClient dio;

  AdminOrdersRemote({required this.dio});

  // POST /admin/order/all — returns list wrapped in "message"
  Future<List<AdminOrderItem>> getAllOrders() async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminOrderAll, {});
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminOrderItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> assignRider({
    required String ordersId,
    required String riderId,
  }) async {
    final map = await dio.post(
      '/admin/order/assign-rider',
      FormData.fromMap({
        'orders id': ordersId,
        'rider id': riderId,
      }),
    );
    return checkSuccess(map);
  }
}
