import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/failures/failures.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';

import '../data/admin_product_model.dart';

class AdminProductRemote {
  final DioClient dio;

  AdminProductRemote({required this.dio});

  // GET /admin/product/all — returns list wrapped in "message"
  Future<List<AdminProductListItem>> getAllProducts() async {
    final Map<String, dynamic> map =
        await dio.get(ApiEndpoints.adminProductAll);
    checkSuccess(map);
    final list = map['message'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /admin/product/id?product id=<id>
  Future<AdminProductDetail> getProductById(String productId) async {
    final Map<String, dynamic> map = await dio.get(
      ApiEndpoints.adminProductById,
      query: {'product id': productId},
    );
    checkSuccess(map);
    // Server wraps detail inside "message": { ... }
    final data = map['message'] as Map<String, dynamic>;
    return AdminProductDetail.fromMap(data);
  }

  // POST /admin/product/approve
  // Server reads: c.PostForm("product id"), c.PostForm("approved")
  Future<bool> approveProduct(String productId, bool approved) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminProductApprove,
      {'product id': productId, 'approved': approved.toString()},
    );
    return checkSuccess(map);
  }

  // POST /admin/product/hide
  // Server reads: c.PostForm("product id"), c.PostForm("hide")
  Future<bool> hideProduct(String productId, bool hide) async {
    final Map<String, dynamic> map = await dio.post(
      ApiEndpoints.adminProductHide,
      {'product id': productId, 'hide': hide.toString()},
    );
    return checkSuccess(map);
  }
}
