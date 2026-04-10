import 'dart:convert';

class ProductInput {
  final String name;
  final String brand;
  final String description;
  final String shortDescription;
  final double pricePerUnit;
  final String unit;
  final double discount;
  final String productCategory;
  final String deliveryCategory;
  final int stock;
  final List<String> photos;
  final Map<String, String> categoryAttributes;

  ProductInput({
    required this.name,
    required this.brand,
    required this.description,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.unit,
    required this.discount,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.photos,
    this.categoryAttributes = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      "Name": name,
      "brand": brand,
      "description": description,
      "short descriptions": shortDescription,
      "price per unit": pricePerUnit,
      "unit": unit,
      "discount": discount,
      "product catagory": productCategory,
      "delivary category": deliveryCategory,
      "stock": stock,
      "Photos": photos,
      "category attributes": jsonEncode(categoryAttributes),
    };
  }
}