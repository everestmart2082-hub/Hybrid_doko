import 'package:dio/dio.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_category_model.dart';

class AdminCategoryRemote {
  final DioClient dio;

  AdminCategoryRemote({required this.dio});

  // GET /category/all — public endpoint (no auth needed)
  Future<List<CategoryListItem>> getAllCategories() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.categoryAll);
    checkSuccess(map);
    final list = map['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => CategoryListItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // POST /admin/categories/add
  // Server reads: c.PostForm("name"), "quick/normal", "required", "others"
  Future<bool> addCategory(AdminCategoryRequest req) async {
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminCategoryAdd, FormData.fromMap(req.toMap()));
    return checkSuccess(map);
  }

  // POST /admin/categories/edit
  // Server reads: c.PostForm("category id") + same fields as add
  Future<bool> editCategory(String categoryId, AdminCategoryRequest req) async {
    final body = <String, dynamic>{
      'category id': categoryId,
      ...req.toMap(),
    };
    final Map<String, dynamic> map =
        await dio.post(ApiEndpoints.adminCategoryEdit, FormData.fromMap(body));
    return checkSuccess(map);
  }

  // POST /admin/categories/hide
  // Server reads: c.PostForm("category id"), c.PostForm("hidden")
  Future<bool> hideCategory(String categoryId, bool hidden) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminCategoryHide,
      FormData.fromMap({'category id': categoryId, 'hidden': hidden.toString()}),
    );
    return checkSuccess(map);
  }
}
