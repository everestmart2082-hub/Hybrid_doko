
import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/order_model.dart';
import '../data/otp_model.dart';

class RiderOrderRemote {
  final DioClient dio;

  RiderOrderRemote({required this.dio});

  Future<List<RiderOrderGroup>> fetchOrders({
    int page = 1,
    int limit = 20,
    String? searchText,
    String? status,
    String? deliveryCategory,
  }) async {
    final response = await dio.post(
      ApiEndpoints.orderAll,
      FormData.fromMap({
        "page": page,
        "limit": limit,
        "search text": searchText,
        "status": status,
        "delivary category": deliveryCategory,
      }),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] != true) {
      throw Exception(data['message'] ?? "Failed to fetch orders");
    }

    // Backend wrapper: message = ["orders id", mappedList]
    final wrapper = data['message'];
    final mappedList = (wrapper is List && wrapper.length >= 2 && wrapper[1] is List)
        ? (wrapper[1] as List)
        : (wrapper is List ? wrapper : const []);

    final items = mappedList
        .whereType<Map>()
        .map((e) => RiderOrderItem.fromJson(e.cast<String, dynamic>()))
        .toList();

    final itemsByOrderId = <String, List<RiderOrderItem>>{};
    for (final item in items) {
      itemsByOrderId.putIfAbsent(item.orderId, () => []).add(item);
    }

    final groups = itemsByOrderId.entries
        .map((entry) => RiderOrderGroup(
              orderId: entry.key,
              items: entry.value,
            ))
        .toList();

    return groups;
  }

  Future<String> generateOtp(GenerateOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.generateOtp,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      return data['message'] ?? "OTP generated";
    } else {
      throw Exception(data['message'] ?? "Failed to generate OTP");
    }
  }

  Future<String> markDelivered(DeliverOrderOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.orderDelivered,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      return data['message'] ?? "Order delivered";
    } else {
      throw Exception(data['message'] ?? "Failed to mark delivered");
    }
  }

  Future<String> acceptOrder(AcceptOrderModel model) async {
    final response = await dio.post(
      ApiEndpoints.orderAccept,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      return data['message'] ?? "Order accepted";
    }

    throw Exception(data['message'] ?? "Failed to accept order");
  }

  Future<String> rejectOrder(RejectOrderModel model) async {
    final response = await dio.post(
      ApiEndpoints.orderReject,
      FormData.fromMap(model.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      return data['message'] ?? "Order rejected";
    }

    throw Exception(data['message'] ?? "Failed to reject order");
  }
}