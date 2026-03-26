import 'package:equatable/equatable.dart';

class ProductQuery extends Equatable {
  final int page;
  final int limit;
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? deliveryCategory;
  final String? vendorId;
  final String? search;
  final bool? inStock;
  final String? brand;
  final double? rating;
  final String? sort;

  const ProductQuery({
    this.page = 1,
    this.limit = 20,
    this.minPrice,
    this.maxPrice,
    this.category,
    this.deliveryCategory,
    this.vendorId,
    this.search,
    this.inStock,
    this.brand,
    this.rating,
    this.sort,
  });

  ProductQuery copyWith({
    int? page,
    int? limit,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? deliveryCategory,
    String? vendorId,
    String? search,
    bool? inStock,
    String? brand,
    double? rating,
    String? sort,
  }) {
    return ProductQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      category: category ?? this.category,
      deliveryCategory: deliveryCategory ?? this.deliveryCategory,
      vendorId: vendorId ?? this.vendorId,
      search: search ?? this.search,
      inStock: inStock ?? this.inStock,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'limit': limit,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'category': category,
      'deliveryCategory': deliveryCategory,
      'vendorId': vendorId,
      'search': search,
      'inStock': inStock,
      'brand': brand,
      'rating': rating,
      'sort': sort,
    };
  }

  factory ProductQuery.fromMap(Map<String, dynamic> map) {
    return ProductQuery(
      page: map['page'] ?? 1,
      limit: map['limit'] ?? 20,
      minPrice: map['minPrice'] != null ? map['minPrice'] * 1.0 : null,
      maxPrice: map['maxPrice'] != null ? map['maxPrice'] * 1.0 : null,
      category: map['category'],
      deliveryCategory: map['deliveryCategory'],
      vendorId: map['vendorId'],
      search: map['search'],
      inStock: map['inStock'],
      brand: map['brand'],
      rating: map['rating'] != null ? map['rating'] * 1.0 : null,
      sort: map['sort'],
    );
  }

  @override
  List<Object?> get props => [
        page,
        limit,
        minPrice,
        maxPrice,
        category,
        deliveryCategory,
        vendorId,
        search,
        inStock,
        brand,
        rating,
        sort,
      ];
}