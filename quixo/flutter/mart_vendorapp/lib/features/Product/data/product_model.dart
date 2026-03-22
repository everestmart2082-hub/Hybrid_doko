class Product {
  final String id;
  final String name;
  final String shortDescription;
  final double pricePerUnit;
  final String productCategory;
  final String deliveryCategory;
  final int stock;
  final String brandName;

  Product({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.brandName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map["product id"].toString(),
      name: map["name"] ?? "",
      shortDescription: map["short description"] ?? "",
      pricePerUnit: (map["price per unit"] ?? 0).toDouble(),
      productCategory: map["product category"] ?? "",
      deliveryCategory: map["delivary category"] ?? "",
      stock: map["stock"] ?? 0,
      brandName: map["brand name"] ?? "",
    );
  }
}