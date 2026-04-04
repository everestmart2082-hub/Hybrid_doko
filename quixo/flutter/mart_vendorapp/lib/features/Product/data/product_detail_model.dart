String _mongoFieldToHexString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final oid = v[r'$oid'];
    if (oid is String) return oid;
  }
  return v.toString();
}

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
    final ph = map["photos"] ?? map["Photos"];
    List<String> photos = [];
    if (ph is List) {
      photos = ph.map((e) => e.toString()).toList();
    }
    return ProductDetail(
      id: _mongoFieldToHexString(map["id"]),
      name: map["Name"]?.toString() ?? map["name"]?.toString() ?? "",
      brand: map["brand"]?.toString() ?? "",
      description: map["description"]?.toString() ?? "",
      shortDescription: map["short description"]?.toString() ??
          map["short descriptions"]?.toString() ??
          "",
      price: (map["price per unit"] ?? 0).toDouble(),
      unit: map["unit"]?.toString() ?? "",
      discount: (map["discount"] ?? 0).toDouble(),
      productCategory: _mongoFieldToHexString(
        map["product catagory"] ?? map["product category"],
      ),
      deliveryCategory: map["delivary category"]?.toString() ?? "",
      stock: map["stock"] is int ? map["stock"] as int : int.tryParse('${map["stock"] ?? 0}') ?? 0,
      photos: photos,
      vendorId: map["vender id"]?.toString() ?? "",
      vendorName: map["vender name"]?.toString() ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
    );
  }
}