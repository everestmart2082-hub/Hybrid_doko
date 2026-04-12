
import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../profile/data/rider_profile_response_model.dart';
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
        'page': '$page',
        'limit': '$limit',
      }),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'Failed to load notifications');
    }

    final raw = data['message'];
    if (raw is! List) {
      return _fallbackFromProfile();
    }

    final list = <RiderNotificationModel>[];
    for (final e in raw) {
      if (e is Map) {
        list.add(RiderNotificationModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    if (list.isEmpty) {
      final fb = await _fallbackFromProfile();
      if (fb.isNotEmpty) return fb;
    }
    return list;
  }

  Future<List<RiderNotificationModel>> _fallbackFromProfile() async {
    try {
      final response = await dio.post(ApiEndpoints.getProfile, {});
      final map = response is Map<String, dynamic>
          ? response
          : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
      final prof = RiderProfileResponseModel.fromJson(map);
      final text = prof.adminMessage?.trim() ?? '';
      if (text.isEmpty) return [];
      return [
        RiderNotificationModel(
          message: text,
          date: DateTime.now(),
        ),
      ];
    } catch (_) {
      return [];
    }
  }
}
