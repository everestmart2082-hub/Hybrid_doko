import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_rider_model.dart';

class AdminRiderRemote {
  final DioClient dio;

  AdminRiderRemote({required this.dio});

  // GET /admin/rider/all
  Future<List<AdminRiderItem>> getAllRiders() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.adminRiderAll);
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminRiderItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // POST /admin/rider/approve
  Future<bool> approveRider(String riderId, bool approved) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminRiderApprove,
      FormData.fromMap({'rider id': riderId, 'approved': approved.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/rider/suspension
  Future<bool> suspendRider(String riderId, bool suspended) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminRiderSuspension,
      FormData.fromMap({'rider id': riderId, 'suspended': suspended.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/rider/blacklist
  Future<bool> blacklistRider(String riderId, bool blacklisted) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminRiderBlacklist,
      FormData.fromMap({'rider id': riderId, 'blacklisted': blacklisted.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/rider/notification
  Future<bool> sendNotification(String riderId, String message) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminRiderNotification,
      FormData.fromMap({'rider id': riderId, 'message': message}),
    );
    return checkSuccess(map);
  }

  // POST /admin/rider/violations/update
  Future<bool> updateViolations(String riderId, List<String> violations) async {
    final formData = FormData.fromMap({
      'rider id': riderId,
      if (violations.isNotEmpty) 'violations[]': violations,
      if (violations.isEmpty) 'violations': '',
    });
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminRiderViolations,
      formData,
    );
    return checkSuccess(map);
  }
}
