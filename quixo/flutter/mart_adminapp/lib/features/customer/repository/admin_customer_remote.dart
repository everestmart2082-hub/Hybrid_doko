import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_customer_model.dart';

class AdminCustomerRemote {
  final DioClient dio;

  AdminCustomerRemote({required this.dio});

  // GET /admin/user/all
  Future<List<AdminUserItem>> getAllUsers() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.adminUserAll);
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminUserItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // POST /admin/user/approve
  Future<bool> approveUser(String userId, bool approved) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminUserApprove,
      FormData.fromMap({'user id': userId, 'approved': approved.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/user/suspension
  Future<bool> suspendUser(String userId, bool suspended) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminUserSuspension,
      FormData.fromMap({'user id': userId, 'suspended': suspended.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/user/blacklist
  Future<bool> blacklistUser(String userId, bool blacklisted) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminUserBlacklist,
      FormData.fromMap({'user id': userId, 'blacklisted': blacklisted.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/user/notification
  Future<bool> sendNotification(String userId, String message) async {
    final raw = await dio.post(
      ApiEndpoints.adminUserNotification,
      {'user id': userId, 'message': message},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final map = Map<String, dynamic>.from(raw as Map);
    return checkSuccess(map);
  }

  // POST /admin/user/violations/update
  Future<bool> updateViolations(String userId, List<String> violations) async {
    final formData = FormData.fromMap({
      'user id': userId,
      if (violations.isNotEmpty) 'violations[]': violations,
      if (violations.isEmpty) 'violations': '',
    });
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminUserViolations,
      formData,
    );
    return checkSuccess(map);
  }
}
