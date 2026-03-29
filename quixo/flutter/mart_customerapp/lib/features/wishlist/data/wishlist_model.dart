import 'package:equatable/equatable.dart';

class WishlistItemModel extends Equatable {
  final String productId;
  final String name;
  final String image;
  final String number;
  final double pricePerUnit;
  final String unit;
  final String deliveryCategory;
  final String productCategory;
  final String brandName;

  const WishlistItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.number,
    required this.pricePerUnit,
    required this.unit,
    required this.deliveryCategory,
    required this.productCategory,
    required this.brandName,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      productId: (json["product id"] ?? json["product_id"] ?? "").toString(),
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      number: (json["number"] ?? "").toString(),
      pricePerUnit: (json["priceperunit"] as num?)?.toDouble() ?? 0.0,
      unit: json["unit"] ?? "",
      deliveryCategory: json["delivary category"] ?? json["delivary_category"] ?? "",
      productCategory: json["product category"] ?? json["product_category"] ?? "",
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
        brandName
      ];
}