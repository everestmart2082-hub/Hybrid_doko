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
  });

  factory ProductDetail.fromMap(Map<String, dynamic> map) {
    return ProductDetail(
      id: map["id"].toString(),
      name: map["name"] ?? "",
      brand: map["brand"] ?? "",
      description: map["description"] ?? "",
      shortDescription: map["short descriptions"] ?? "",
      price: (map["price per unit"] ?? 0).toDouble(),
      unit: map["unit"] ?? "",
      discount: (map["discount"] ?? 0).toDouble(),
      productCategory: map["product category"] ?? "",
      deliveryCategory: map["delivary category"] ?? "",
      stock: map["stock"] ?? 0,
      photos: List<String>.from(map["Photos"] ?? []),
      vendorId: map["vender id"] ?? "",
      vendorName: map["vender name"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
    );
  }
}