
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
      {
        "page": page,
        "limit": limit,
        "search text": searchText,
        "status": status,
        "delivary category": deliveryCategory,
      },
    );

    if (response.data['success'] == true) {
      final list = (response.data['message'] as List<dynamic>? ?? [])
          .map((e) => RiderOrderGroup.fromJson(e))
          .toList();
      return list;
    } else {
      throw Exception(response.data['message'] ?? "Failed to fetch orders");
    }
  }

  Future<String> generateOtp(GenerateOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.generateOtp,
      model.toJson()
    );

    if (response.data['success'] == true) {
      return response.data['message'] ?? "OTP generated";
    } else {
      throw Exception(response.data['message'] ?? "Failed to generate OTP");
    }
  }

  Future<String> markDelivered(DeliverOrderOtpModel model) async {
    final response = await dio.post(
      ApiEndpoints.orderDelivered,
      model.toJson(),
    );

    if (response.data['success'] == true) {
      return response.data['message'] ?? "Order delivered";
    } else {
      throw Exception(response.data['message'] ?? "Failed to mark delivered");
    }
  }
}