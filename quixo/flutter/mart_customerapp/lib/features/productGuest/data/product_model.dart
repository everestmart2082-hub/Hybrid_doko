import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
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
  final String vendorId;
  final String vendorName;
  final double rating;

  const ProductModel({
    required this.id,
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
    required this.vendorId,
    required this.vendorName,
    required this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        description,
        shortDescription,
        pricePerUnit,
        unit,
        discount,
        productCategory,
        deliveryCategory,
        stock,
        photos,
        vendorId,
        vendorName,
        rating,
      ];

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    String? shortDescription,
    double? pricePerUnit,
    String? unit,
    double? discount,
    String? productCategory,
    String? deliveryCategory,
    int? stock,
    List<String>? photos,
    String? vendorId,
    String? vendorName,
    double? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unit: unit ?? this.unit,
      discount: discount ?? this.discount,
      productCategory: productCategory ?? this.productCategory,
      deliveryCategory: deliveryCategory ?? this.deliveryCategory,
      stock: stock ?? this.stock,
      photos: photos ?? this.photos,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'shortDescription': shortDescription,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'discount': discount,
      'productCategory': productCategory,
      'deliveryCategory': deliveryCategory,
      'stock': stock,
      'photos': photos,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'rating': rating,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: (map['id'] ?? '').toString(),
      name: map['Name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      description: map['short description'] as String? ?? '', // API only sends short_description
      shortDescription: map['short description'] as String? ?? '',
      pricePerUnit: (map['price per unit'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? '',
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      productCategory: map['product catagory'] as String? ?? '',
      deliveryCategory: map['delivary category'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      photos: List<String>.from(map['photos'] ?? []),
      vendorId: map['vender id'] as String? ?? '',
      vendorName: map['vender name'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}