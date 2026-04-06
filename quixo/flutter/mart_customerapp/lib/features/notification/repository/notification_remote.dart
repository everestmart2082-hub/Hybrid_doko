import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../data/notification_model.dart';
import '../data/notification_query_model.dart';

class NotificationRemote {
  final DioClient dio;

  NotificationRemote({required this.dio});

  Future<List<NotificationModel>> getNotifications(
      NotificationQueryModel query) async {
    final response = await dio.post(
      '/user/notification',
      FormData.fromMap(query.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] == true) {
      final list = data['message'] as List? ?? const [];
      return list
          .map((e) => NotificationModel.fromJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch notifications');
  }
}
