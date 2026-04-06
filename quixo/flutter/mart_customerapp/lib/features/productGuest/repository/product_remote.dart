
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';
import '../data/product_list_item_model.dart';
import '../data/product_model.dart';

class ProductGuestRemote {
  final DioClient dio;

  ProductGuestRemote({required this.dio});

  Future<ProductModel> getProductById(String id) async {
    final map = await dio.get("/product/id", query: {"product id": id});
    _checkSuccess(map);
    return ProductModel.fromMap(map['message'] as Map<String, dynamic>);
  }

  Future<List<ProductListItem>> getAllProducts({
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? productCategory,
    String? deliveryCategory,
    String? vendorId,
    String? searchText,
    bool? stock,
    String? brand,
    double? rating,
  }) async {
    final query = {
      'page': page,
      'limit': limit,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (productCategory != null) 'product category': productCategory,
      if (deliveryCategory != null) 'deliveryCategory': deliveryCategory,
      if (vendorId != null) 'vender id': vendorId,
      if (searchText != null) 'searchText': searchText,
      if (stock != null) 'stock': stock,
      if (brand != null) 'brand': brand,
      if (rating != null) 'rating': rating,
    };

    final map = await dio.get("/product/all", query: query);
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<ProductListItem>> getRecommendedProducts() async {
    final map = await dio.get("/product/recommended");
    _checkSuccess(map);

    final list = (map['message'] as List)
        .map((e) => ProductListItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  void _checkSuccess(Map<String, dynamic> map) {
    if (!(map['success'] as bool)) {
      throw UnknownFailure( map['message']?.toString() ?? "Something went wrong");
    }
  }
}