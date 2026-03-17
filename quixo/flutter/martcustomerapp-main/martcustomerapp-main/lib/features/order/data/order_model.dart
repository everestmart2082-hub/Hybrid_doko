import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String orderId;
  final String productName;
  final String productId;
  final String status;
  final String deliveryCategory;
  final String riderName;
  final String riderNumber;

  const OrderModel({
    required this.orderId,
    required this.productName,
    required this.productId,
    required this.status,
    required this.deliveryCategory,
    required this.riderName,
    required this.riderNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json["order_id"] ?? "",
      productName: json["product_name"] ?? "",
      productId: json["product_id"] ?? "",
      status: json["status"] ?? "",
      deliveryCategory: json["delivery_category"] ?? "",
      riderName: json["rider_name"] ?? "",
      riderNumber: json["rider_number"] ?? "",
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        productName,
        productId,
        status,
        deliveryCategory,
        riderName,
        riderNumber,
      ];
}