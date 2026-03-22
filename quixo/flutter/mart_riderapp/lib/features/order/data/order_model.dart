import 'package:equatable/equatable.dart';

class RiderOrderItem extends Equatable {
  final String orderId;
  final String orderStatus;
  final String productCategory;
  final String deliveryCategory;
  final DateTime orderTime;
  final String productId;
  final int productNumber;

  const RiderOrderItem({
    required this.orderId,
    required this.orderStatus,
    required this.productCategory,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.productNumber,
  });

  factory RiderOrderItem.fromJson(Map<String, dynamic> json) {
    return RiderOrderItem(
      orderId: json['order id'] ?? "",
      orderStatus: json['order status'] ?? "",
      productCategory: json['product category'] ?? "",
      deliveryCategory: json['delivary category'] ?? "",
      orderTime: DateTime.tryParse(json['order time'] ?? "") ?? DateTime.now(),
      productId: json['product id'] ?? "",
      productNumber: json['product number'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [orderId, orderStatus, productCategory, deliveryCategory, orderTime, productId, productNumber];
}

class RiderOrderGroup extends Equatable {
  final String orderId;
  final List<RiderOrderItem> items;

  const RiderOrderGroup({
    required this.orderId,
    required this.items,
  });

  factory RiderOrderGroup.fromJson(Map<String, dynamic> json) {
    final innerList = (json['orders'] as List<dynamic>? ?? [])
        .map((e) => RiderOrderItem.fromJson(e))
        .toList();
    return RiderOrderGroup(
      orderId: json['order id'] ?? "",
      items: innerList,
    );
  }

  @override
  List<Object?> get props => [orderId, items];
}