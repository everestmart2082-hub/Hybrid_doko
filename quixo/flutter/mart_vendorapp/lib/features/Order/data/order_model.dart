import 'package:equatable/equatable.dart';

class VendorOrder extends Equatable {
  final String orderId;
  final String orderStatus;
  final String productCategory;
  final String deliveryCategory;
  final String orderTime;
  final String productId;
  final int productNumber;
  final String riderName;
  final String riderNumber;

  const VendorOrder({
    required this.orderId,
    required this.orderStatus,
    required this.productCategory,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.productNumber,
    required this.riderName,
    required this.riderNumber,
  });

  factory VendorOrder.fromMap(Map<String, dynamic> map) {
    return VendorOrder(
      orderId: map["order id"].toString(),
      orderStatus: map["order status"] ?? "",
      productCategory: map["product category"] ?? "",
      deliveryCategory: map["delivary category"] ?? "",
      orderTime: map["order time"] ?? "",
      productId: map["product id"].toString(),
      productNumber: map["product number"] ?? 0,
      riderName: map["rider name"] ?? "",
      riderNumber: map["rider number"] ?? "",
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        orderStatus,
        productCategory,
        deliveryCategory,
        orderTime,
        productId,
        productNumber,
        riderName,
        riderNumber,
      ];
}