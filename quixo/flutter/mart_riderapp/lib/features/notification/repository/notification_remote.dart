
import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../data/notification_model.dart';

class RiderNotificationRemote {
  final DioClient dio;

  RiderNotificationRemote({required this.dio});

  Future<List<RiderNotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.post(
      ApiEndpoints.Notification,
      FormData.fromMap({
        "page": page,
        "limit": limit,
      }),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data["success"] == true) {
      final list = (data["message"] as List<dynamic>)
          .map((e) => RiderNotificationModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      return list;
    } else {
      throw Exception(data["message"] ?? "Failed to load notifications");
    }
  }
}