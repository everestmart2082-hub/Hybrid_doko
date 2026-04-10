import 'package:equatable/equatable.dart';

String _mongoFieldToHexString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
  }
  return v.toString();
}

class WishlistItemModel extends Equatable {
  final String wishlistId;
  final String productId;
  final String name;
  final String image;
  final String number;
  final double pricePerUnit;
  final double discount;
  final String unit;
  final String deliveryCategory;
  final String productCategory;
  final String brandName;

  const WishlistItemModel({
    required this.wishlistId,
    required this.productId,
    required this.name,
    required this.image,
    required this.number,
    required this.pricePerUnit,
    required this.discount,
    required this.unit,
    required this.deliveryCategory,
    required this.productCategory,
    required this.brandName,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final photos = json["photos"];
    final fallbackImage = photos is List && photos.isNotEmpty
        ? photos.first.toString()
        : "";
    return WishlistItemModel(
      wishlistId: _mongoFieldToHexString(
        json["wishlist id"] ?? json["wishlist_id"] ?? json["_id"],
      ),
      productId: _mongoFieldToHexString(
        json["product id"] ?? json["product_id"],
      ),
      name: json["name"] ?? "",
      image: (json["image"] ?? fallbackImage).toString(),
      number: (json["number"] ?? "").toString(),
      pricePerUnit: (json["priceperunit"] as num?)?.toDouble() ?? 0.0,
      discount: (json["discount"] as num?)?.toDouble() ?? 0.0,
      unit: json["unit"] ?? "",
      deliveryCategory:
          json["delivary category"] ?? json["delivary_category"] ?? "",
      productCategory:
          json["product category"] ?? json["product_category"] ?? "",
      brandName: json["brandname"] ?? "",
    );
  }

  @override
  List<Object?> get props => [
    wishlistId,
    productId,
    name,
    image,
    number,
    pricePerUnit,
    discount,
    unit,
    deliveryCategory,
    productCategory,
    brandName,
  ];
}
