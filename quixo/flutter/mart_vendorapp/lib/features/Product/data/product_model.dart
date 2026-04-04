class Product {
  final String id;
  final String name;
  final String shortDescription;
  final double pricePerUnit;
  final String productCategory;
  final String deliveryCategory;
  final int stock;
  final String brandName;
  final List<String> photos;

  Product({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.pricePerUnit,
    required this.productCategory,
    required this.deliveryCategory,
    required this.stock,
    required this.brandName,
    this.photos = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    List<String> photoList = [];
    final ph = map["photos"];
    if (ph is List) {
      photoList = ph.map((e) => e.toString()).toList();
    }
    return Product(
      id: (map["Product id"] ?? map["product id"] ?? '').toString(),
      name: map["name"] ?? "",
      shortDescription: map["short description"] ?? "",
      pricePerUnit: (map["price per unit"] ?? 0).toDouble(),
      productCategory:
          map["product catagory"]?.toString() ?? map["product category"]?.toString() ?? "",
      deliveryCategory: map["delivary category"]?.toString() ?? "",
      stock: (map["stock"] is int) ? map["stock"] as int : int.tryParse('${map["stock"] ?? 0}') ?? 0,
      brandName: map["brand name"]?.toString() ?? "",
      photos: photoList,
    );
  }
}