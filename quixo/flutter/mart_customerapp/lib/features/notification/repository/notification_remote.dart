import 'package:dio/dio.dart';

import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';

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
      FormData.fromMap(query.toJson()),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'Failed to fetch notifications');
    }

    final raw = data['message'];
    if (raw is! List) {
      return _fallbackFromProfile();
    }

    final out = <NotificationModel>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(NotificationModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    if (out.isEmpty) {
      final fb = await _fallbackFromProfile();
      if (fb.isNotEmpty) return fb;
    }
    return out;
  }

  Future<List<NotificationModel>> _fallbackFromProfile() async {
    try {
      final raw = await dio.post(ApiEndpoints.profileGet, {});
      final map = Map<String, dynamic>.from(raw as Map);
      checkSuccess(map);
      final msg = map['message'];
      if (msg is! Map) return [];
      final m = Map<String, dynamic>.from(msg);
      final text = (m['admin_message'] ?? '').toString().trim();
      if (text.isEmpty) return [];
      return [NotificationModel(message: text, date: '')];
    } catch (_) {
      return [];
    }
  }
}
