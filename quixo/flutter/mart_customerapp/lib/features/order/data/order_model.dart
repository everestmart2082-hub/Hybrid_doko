import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String ordersId;
  final String orderId;
  final String productName;
  final String productId;
  final String productImage;
  final String brandName;
  final String shortDescription;
  final int productNumber;
  final String status;
  final String deliveryCategory;
  final String riderName;
  final String riderNumber;

  const OrderModel({
    required this.ordersId,
    required this.orderId,
    required this.productName,
    required this.productId,
    required this.productImage,
    required this.brandName,
    required this.shortDescription,
    required this.productNumber,
    required this.status,
    required this.deliveryCategory,
    required this.riderName,
    required this.riderNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      ordersId: (json["orders id"] ?? json["orders_id"] ?? "").toString(),
      orderId: (json["order id"] ?? json["_id"] ?? "").toString(),
      productName: json["product name"] ?? "",
      productId: (json["product id"] ?? json["product_id"] ?? "").toString(),
      productImage: (json["product image"] ?? "").toString(),
      brandName: (json["brand name"] ?? "").toString(),
      shortDescription: (json["short description"] ?? "").toString(),
      productNumber: (json["product number"] as num?)?.toInt() ?? 0,
      status: json["status"] ?? "",
      deliveryCategory: json["delivery category"] ?? "",
      riderName: json["rider name"] ?? "",
      riderNumber: json["rider number"] ?? "",
    );
  }

  @override
  List<Object?> get props => [
        ordersId,
        orderId,
        productName,
        productId,
        productImage,
        brandName,
        shortDescription,
        productNumber,
        status,
        deliveryCategory,
        riderName,
        riderNumber,
      ];
}