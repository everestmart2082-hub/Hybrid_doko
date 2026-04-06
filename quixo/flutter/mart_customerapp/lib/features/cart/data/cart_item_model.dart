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

class CartItemModel extends Equatable {
  final String productId;
  final String name;
  final String image;
  final int number;
  final double pricePerUnit;
  final String unit;
  final String deliveryCategory;
  final String productCategory;
  final String brandName;
  final String id;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.number,
    required this.pricePerUnit,
    required this.unit,
    required this.deliveryCategory,
    required this.productCategory,
    required this.brandName,
    required this.id,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final photos = json["photos"];
    final fallbackImage = photos is List && photos.isNotEmpty
        ? photos.first.toString()
        : "";
    return CartItemModel(
      id: _mongoFieldToHexString(json["cart id"] ?? json["id"] ?? json["_id"]),
      productId: _mongoFieldToHexString(
        json["product id"] ?? json["product_id"],
      ),
      name: json["name"] ?? "",
      image: (json["image"] ?? fallbackImage).toString(),
      number: (json["number"] as num?)?.toInt() ?? 0,
      pricePerUnit: (json["priceperunit"] as num?)?.toDouble() ?? 0.0,
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
    productId,
    name,
    image,
    number,
    pricePerUnit,
    unit,
    deliveryCategory,
    productCategory,
    brandName,
    id,
  ];
}
