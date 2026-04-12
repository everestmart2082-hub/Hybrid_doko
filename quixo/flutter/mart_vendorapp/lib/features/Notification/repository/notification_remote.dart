
import 'package:dio/dio.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/notification_model.dart';

class NotificationRemote {

  final DioClient dio;

  NotificationRemote({required this.dio});

  Future<List<NotificationModel>> getNotifications(
      int page,
      int limit,
  ) async {

    final Map<String, dynamic> map = Map<String, dynamic>.from(
      await dio.post(
        ApiEndpoints.notification,
        FormData.fromMap({
          'page': '$page',
          'limit': '$limit',
        }),
      ) as Map,
    );

    checkSuccess(map);

    final raw = map['message'];
    if (raw is! List) {
      return _fallbackFromProfile();
    }

    final out = <NotificationModel>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(NotificationModel.fromMap(Map<String, dynamic>.from(e)));
      }
    }

    if (out.isEmpty) {
      final fb = await _fallbackFromProfile();
      if (fb.isNotEmpty) return fb;
    }
    return out;
  }

  /// If the notifications collection is empty, show cumulative admin text from profile.
  Future<List<NotificationModel>> _fallbackFromProfile() async {
    try {
      final raw = await dio.post(ApiEndpoints.profile, {});
      final map = Map<String, dynamic>.from(raw as Map);
      if (!_isSuccess(map['success'])) return [];
      final data = map['data'];
      if (data is! Map) return [];
      final m = Map<String, dynamic>.from(data);
      final text = (m['admin_message'] ?? '').toString().trim();
      if (text.isEmpty) return [];
      return [
        NotificationModel(
          message: text,
          date: '',
        ),
      ];
    } catch (_) {
      return [];
    }
  }

  bool _isSuccess(dynamic v) {
    if (v == true || v == 1) return true;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1';
    }
    return false;
  }

}
