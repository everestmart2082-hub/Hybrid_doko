import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:quickmartcustomer/core/utils/mongo_json.dart';

class ProductListItem extends Equatable {
  final String id;
  final String name;
  final String shortDescription;
  final double pricePerUnit;
  final double discount;
  final String productCategory;
  final String deliveryCategory;
  final int stock;
  final String brandName;
  final List<String> images;

  const ProductListItem({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    this.discount = 0,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.brandName,
    required this.images,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        shortDescription,
        pricePerUnit,
        discount,
        productCategory,
        deliveryCategory,
        stock,
        brandName,
        images,
      ];

  ProductListItem copyWith({
    String? id,
    String? name,
    String? shortDescription,
    double? pricePerUnit,
    double? discount,
    String? productCategory,
    String? deliveryCategory,
    int? stock,
    String? brandName,
    List<String>? images,
  }) {
    return ProductListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      discount: discount ?? this.discount,
      productCategory: productCategory ?? this.productCategory,
      deliveryCategory: deliveryCategory ?? this.deliveryCategory,
      stock: stock ?? this.stock,
      brandName: brandName ?? this.brandName,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'pricePerUnit': pricePerUnit,
      'discount': discount,
      'productCategory': productCategory,
      'deliveryCategory': deliveryCategory,
      'stock': stock,
      'brandName': brandName,
      'images': images,
    };
  }

  factory ProductListItem.fromMap(Map<String, dynamic> map) {
    return ProductListItem(
      id: mongoIdToString(map['Product id'] ?? map['id']),
      name: map['name'] as String? ?? '',
      shortDescription: map['short description'] as String? ?? '',
      pricePerUnit: (map['price per unit'] as num?)?.toDouble() ?? 0.0,
      discount: parseDiscountField(map['discount']),
      productCategory: mongoIdToString(
        map['product catagory'] ?? map['product category'],
      ),
      deliveryCategory: map['delivary category'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brandName: map['brand name'] as String? ?? '',
      images: List<String>.from(map['photos'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductListItem.fromJson(String source) =>
      ProductListItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
