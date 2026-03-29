import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_constant_model.dart';

class AdminSettingsRemote {
  final DioClient dio;

  AdminSettingsRemote({required this.dio});

  // POST /admin/changeConstants
  // Server reads:
  //   c.PostForm("name")         → constant name (e.g. "delivery_types")
  //   c.PostForm("doingwhat")    → "add" | "remove" | "" (replace)
  //   c.PostFormArray("type list []") → items to add/remove/set
  Future<bool> changeConstants(AdminConstantUpdateRequest req) async {
    final formData = FormData.fromMap({
      ...req.toMap(),
      'type list []': req.typesList, // repeated key for each item in the array
    });
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminChangeConstants, formData);
    return checkSuccess(map);
  }
}
