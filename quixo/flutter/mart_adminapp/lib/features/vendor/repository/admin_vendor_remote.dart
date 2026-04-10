import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_vendor_model.dart';

class AdminVendorRemote {
  final DioClient dio;

  AdminVendorRemote({required this.dio});

  // GET /admin/vender/all
  Future<List<AdminVendorItem>> getAllVendors() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.adminVendorAll);
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminVendorItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // POST /admin/vender/approve — approved: true/false
  Future<bool> approveVendor(String venderId, bool approved) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminVendorApprove,
      FormData.fromMap({'vender id': venderId, 'approved': approved.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/vender/suspension — suspended: true/false
  Future<bool> suspendVendor(String venderId, bool suspended) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminVendorSuspension,
      FormData.fromMap({'vender id': venderId, 'suspended': suspended.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/vender/blacklist — blacklisted: true/false
  Future<bool> blacklistVendor(String venderId, bool blacklisted) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminVendorBlacklist,
      FormData.fromMap({'vender id': venderId, 'blacklisted': blacklisted.toString()}),
    );
    return checkSuccess(map);
  }

  // POST /admin/vender/notification
  Future<bool> sendNotification(
      AdminNotificationRequest req) async {
    final raw = await dio.post(
      ApiEndpoints.adminVendorNotification,
      {'vender id': req.targetId, 'message': req.message},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final map = Map<String, dynamic>.from(raw as Map);
    return checkSuccess(map);
  }

  // POST /admin/vender/violations/update — sends violations[] as FormData list
  Future<bool> updateViolations(AdminViolationsRequest req) async {
    final formData = FormData.fromMap({
      'vender id': req.targetId,
      if (req.violations.isNotEmpty) 'violations[]': req.violations,
      if (req.violations.isEmpty) 'violations': '',
    });
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminVendorViolations,
      formData,
    );
    return checkSuccess(map);
  }
}
