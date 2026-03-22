
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
      {
        "page": page,
        "limit": limit,
      },
    );

    if (response.data["success"] == true) {
      final list = (response.data["message"] as List)
          .map((e) => RiderNotificationModel.fromJson(e))
          .toList();

      return list;
    } else {
      throw Exception(response.data["message"] ?? "Failed to load notifications");
    }
  }
}