import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_employee_model.dart';

class AdminEmployeeRemote {
  final DioClient dio;

  AdminEmployeeRemote({required this.dio});

  // GET /admin/employee/all
  Future<List<AdminEmployeeModel>> getAllEmployees() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.adminEmployeeAll);
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminEmployeeModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // POST /admin/employee/add
  // citizenshipFilePath is the local file path for upload (optional)
  Future<bool> addEmployee(
    AdminEmployeeAddRequest req, {
    MultipartFile? citizenshipFile,
  }) async {
    final formMap = <String, dynamic>{...req.toMap()};
    if (citizenshipFile != null) {
      formMap['citizenship'] = citizenshipFile; // server: c.FormFile("citizenship")
    }
    final formData = FormData.fromMap(formMap);
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminEmployeeAdd, formData);
    return checkSuccess(map);
  }

  // POST /admin/employee/update
  Future<bool> updateEmployee(
    AdminEmployeeUpdateRequest req, {
    MultipartFile? citizenshipFile,
  }) async {
    final formMap = <String, dynamic>{...req.toMap()};
    if (citizenshipFile != null) {
      formMap['citizenship file'] = citizenshipFile; // server: c.FormFile("citizenship file")
    }
    final formData = FormData.fromMap(formMap);
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminEmployeeUpdate, formData);
    return checkSuccess(map);
  }

  // POST /admin/employee/update/otp
  // Server reads: c.PostForm("otp"), c.PostForm("phone")
  Future<bool> verifyUpdateOtp(String phone, String otp) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminEmployeeUpdateOtp,
      {'phone': phone, 'otp': otp},
    );
    return checkSuccess(map);
  }

  // DELETE /admin/employee/delete
  // Server reads: c.PostForm("employee id")
  Future<bool> deleteEmployee(String employeeId) async {
    final Map<String, dynamic> map = await dio.delete(
      ApiEndpoints.adminEmployeeDelete,
      {'employee id': employeeId},
    );
    return checkSuccess(map);
  }

  // POST /admin/employee/violations/update
  Future<bool> updateViolations(
      String employeeId, List<String> violations) async {
    final formData = FormData.fromMap({
      'employee id': employeeId,
      'violations[]': violations,
    });
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminEmployeeViolations,
      formData,
    );
    return checkSuccess(map);
  }
}
