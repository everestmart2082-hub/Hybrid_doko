import 'package:equatable/equatable.dart';

// ─── Product List Item ───────────────────────────────────────────────────────
// Maps AdminGetAllProduct server response keys (spaced/lowercased)

class AdminProductListItem extends Equatable {
  final String productId;
  final String name;
  final String shortDescription;
  final num pricePerUnit;
  final String productCategory;
  final String deliveryCategory;
  final num stock;
  final String brandName;
  final bool hidden;
  final bool approved;
  final bool toUpdate; // maps "toupdate"

  const AdminProductListItem({
    required this.productId,
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.brandName,
    required this.hidden,
    required this.approved,
    required this.toUpdate,
  });

  factory AdminProductListItem.fromMap(Map<String, dynamic> map) =>
      AdminProductListItem(
        productId: map['Product id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        shortDescription: map['short description'] as String? ?? '',
        pricePerUnit: (map['price per unit'] as num?) ?? 0,
        productCategory: map['product category']?.toString() ?? '',
        deliveryCategory: map['delivary category'] as String? ?? '',
        stock: (map['stock'] as num?) ?? 0,
        brandName: map['brand name'] as String? ?? '',
        hidden: map['hidden'] as bool? ?? false,
        approved: map['approved'] as bool? ?? false,
        toUpdate: map['toupdate'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        productId, name, shortDescription, pricePerUnit, productCategory,
        deliveryCategory, stock, brandName, hidden, approved, toUpdate,
      ];
}

// ─── Product Detail ──────────────────────────────────────────────────────────
// Maps AdminProductGetByID response — keys have deliberate server typos preserved

class AdminProductDetail extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String shortDescriptions;
  final num pricePerUnit;
  final String unit;
  final num discount;
  final String productCategory;
  final String deliveryCategory;
  final num stock;
  final List<String> photos;
  final String vendorId;
  final num rating;

  const AdminProductDetail({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.shortDescriptions,
    required this.pricePerUnit,
    required this.unit,
    required this.discount,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.photos,
    required this.vendorId,
    required this.rating,
  });

  factory AdminProductDetail.fromMap(Map<String, dynamic> map) {
    // The server wraps detail under map["message"] — caller must unwrap first.
    return AdminProductDetail(
      id: map['id']?.toString() ?? '',
      name: map['Name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      description: map['description'] as String? ?? '',
      shortDescriptions: map['short descriptions'] as String? ?? '',
      pricePerUnit: (map['price per unit'] as num?) ?? 0,
      unit: map['unit ( kg, .. )'] as String? ?? '',
      discount: (map['discount'] as num?) ?? 0,
      productCategory: map['product catagory']?.toString() ?? '',
      deliveryCategory: map['delivary categpory'] as String? ?? '',
      stock: (map['stock : num'] as num?) ?? 0,
      photos: (map['Photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vendorId: map['vender id']?.toString() ?? '',
      rating: (map['rating'] as num?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id, name, brand, description, shortDescriptions, pricePerUnit, unit,
        discount, productCategory, deliveryCategory, stock, photos, vendorId, rating,
      ];
}
