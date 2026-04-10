import 'package:equatable/equatable.dart';

class VendorOrder extends Equatable {
  final String orderId;
  final String ordersId;
  final String orderStatus;
  final String productCategory;
  final String deliveryCategory;
  final String orderTime;
  final String productId;
  final int productNumber;
  final String riderName;
  final String riderNumber;
  final String riderId;
  final String userName;
  final String userNumber;

  const VendorOrder({
    required this.orderId,
    required this.ordersId,
    required this.orderStatus,
    required this.productCategory,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.productNumber,
    required this.riderName,
    required this.riderNumber,
    required this.riderId,
    required this.userName,
    required this.userNumber,
  });

  factory VendorOrder.fromMap(Map<String, dynamic> map) {
    return VendorOrder(
      orderId: map["order id"].toString(),
      ordersId: map["orders id"]?.toString() ?? "",
      orderStatus: map["order status"] ?? "",
      productCategory: map["product category"] ?? "",
      deliveryCategory: map["delivary category"] ?? "",
      orderTime: map["order time"] ?? "",
      productId: map["product id"].toString(),
      productNumber: map["product number"] ?? 0,
      riderName: map["rider name"] ?? "",
      riderNumber: map["rider number"] ?? "",
      riderId: map["rider id"] ?? "",
      userName: map["user name"] ?? "",
      userNumber: map["user number"] ?? "",
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        ordersId,
        orderStatus,
        productCategory,
        deliveryCategory,
        orderTime,
        productId,
        productNumber,
        riderName,
        riderNumber,
        riderId,
        userName,
        userNumber,
      ];
}