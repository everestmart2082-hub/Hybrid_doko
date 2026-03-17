import 'package:quickmartcustomer/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/notification_model.dart';
import '../data/notification_query_model.dart';

class NotificationRemote {
  final DioClient dio;

  NotificationRemote({required this.dio});

  Future<List<NotificationModel>> getNotifications(
      NotificationQueryModel query) async {
    final response = await dio.post(
      ApiEndpoints.getNotifications,
      query.toJson(),
    );

    final data = response.data;

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }
}