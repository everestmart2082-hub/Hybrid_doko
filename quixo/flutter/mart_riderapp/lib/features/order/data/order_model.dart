import 'package:equatable/equatable.dart';

class RiderOrderItem extends Equatable {
  final String ordersId;
  final String orderId;
  final String orderStatus;
  final String productCategory;
  final String productName;
  final String vendorName;
  final String vendorAddress;
  final String userName;
  final String userNumber;
  final String userAddress;
  final String deliveryCategory;
  final DateTime orderTime;
  final String productId;
  final int productNumber;
  final bool accepted;

  const RiderOrderItem({
    required this.ordersId,
    required this.orderId,
    required this.orderStatus,
    required this.productCategory,
    required this.productName,
    required this.vendorName,
    required this.vendorAddress,
    required this.userName,
    required this.userNumber,
    required this.userAddress,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.productNumber,
    required this.accepted,
  });

  factory RiderOrderItem.fromJson(Map<String, dynamic> json) {
    return RiderOrderItem(
      ordersId: (json['orders id'] ?? '').toString(),
      orderId: json['order id'] ?? "",
      orderStatus: json['order status'] ?? "",
      productCategory: json['product category'] ?? "",
      productName: json['product name'] ?? "",
      vendorName: json['vendor name'] ?? "",
      vendorAddress: json['vendor address'] ?? "",
      userName: json['user name'] ?? "",
      userNumber: json['user number'] ?? "",
      userAddress: json['user address'] ?? "",
      deliveryCategory: json['delivary category'] ?? "",
      orderTime: DateTime.tryParse(json['order time'] ?? "") ?? DateTime.now(),
      productId: json['product id'] ?? "",
      productNumber: json['product number'] ?? 0,
      accepted: json['accepted'] == true,
    );
  }

  @override
  List<Object?> get props => [ordersId, orderId, orderStatus, productCategory, productName, vendorName, vendorAddress, userName, userNumber, userAddress, deliveryCategory, orderTime, productId, productNumber, accepted];
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