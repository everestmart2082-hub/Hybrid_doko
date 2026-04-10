import 'package:quickmartvender/features/Product/data/product_review_row.dart';

String _mongoFieldToHexString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
  }
  return v.toString();
}

Map<String, String> _categoryAttrsFromMessage(dynamic v) {
  if (v == null || v is! Map) return {};
  return v.map(
    (k, e) => MapEntry(k.toString(), e?.toString() ?? ''),
  );
}

class ProductDetail {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String shortDescription;
  final double price;
  final String unit;
  final double discount;
  final String productCategory;
  final String deliveryCategory;
  final int stock;
  final List<String> photos;
  final String vendorId;
  final String vendorName;
  final double rating;
  final Map<String, String> categoryAttributes;
  final List<ProductReviewRow> reviews;

  ProductDetail({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.unit,
    required this.discount,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.photos,
    required this.vendorId,
    required this.vendorName,
    required this.rating,
    this.categoryAttributes = const {},
    this.reviews = const [],
  });

  factory ProductDetail.fromMap(Map<String, dynamic> map) {
    final ph = map["photos"] ?? map["Photos"];
    List<String> photos = [];
    if (ph is List) {
      photos = ph.map((e) => e.toString()).toList();
    }
    final List<ProductReviewRow> revs = [];
    final rr = map['reviews'];
    if (rr is List) {
      for (final e in rr) {
        if (e is Map<String, dynamic>) {
          revs.add(ProductReviewRow.fromMap(e));
        } else if (e is Map) {
          revs.add(ProductReviewRow.fromMap(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ProductDetail(
      id: _mongoFieldToHexString(map["id"]),
      name: map["Name"]?.toString() ?? map["name"]?.toString() ?? "",
      brand: map["brand"]?.toString() ?? "",
      description: map["description"]?.toString() ?? "",
      shortDescription: map["short description"]?.toString() ??
          map["short descriptions"]?.toString() ??
          "",
      price: (map["price per unit"] ?? 0).toDouble(),
      unit: map["unit"]?.toString() ?? "",
      discount: (map["discount"] ?? 0).toDouble(),
      productCategory: _mongoFieldToHexString(
        map["product catagory"] ?? map["product category"],
      ),
      deliveryCategory: map["delivary category"]?.toString() ?? "",
      stock: map["stock"] is int ? map["stock"] as int : int.tryParse('${map["stock"] ?? 0}') ?? 0,
      photos: photos,
      vendorId: map["vender id"]?.toString() ?? "",
      vendorName: map["vender name"]?.toString() ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      categoryAttributes: _categoryAttrsFromMessage(map["category attributes"]),
      reviews: revs,
    );
  }
}