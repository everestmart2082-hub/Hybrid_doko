import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_notification_model.dart';

class AdminInboxRemote {
  final DioClient dio;

  AdminInboxRemote({required this.dio});

  /// POST /admin/notifications/all — bearer admin token.
  Future<List<AdminNotificationItem>> fetchNotifications() async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminNotificationsAll, {});
    checkSuccess(map);
    final list = map['message'];
    if (list is! List) {
      return [];
    }
    return list
        .map((e) => AdminNotificationItem.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }
}
