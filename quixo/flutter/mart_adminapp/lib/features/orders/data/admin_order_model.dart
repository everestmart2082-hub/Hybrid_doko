import 'package:equatable/equatable.dart';

// ─── Order List Item ─────────────────────────────────────────────────────────
// Maps AdminOrderAll server response keys (spaced/lowercased, with typos)

class AdminOrderItem extends Equatable {
  final String orderId;
  final String ordersId;
  final String orderStatus;
  final String productCategory;
  final String deliveryCategory;  // server key: "delivary category" (typo preserved)
  final String orderTime;         // server key: "order time"
  final String productId;
  final int productNumber;
  final String venderId;          // server key: "vender id" (typo preserved)
  final String vendorName;
  final String riderId;
  final String riderName;
  final String riderNumber;
  final String userName;
  final String userNumber;

  const AdminOrderItem({
    required this.orderId,
    required this.ordersId,
    required this.orderStatus,
    required this.productCategory,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.productNumber,
    required this.venderId,
    required this.vendorName,
    required this.riderId,
    required this.riderName,
    required this.riderNumber,
    required this.userName,
    required this.userNumber,
  });

  factory AdminOrderItem.fromMap(Map<String, dynamic> map) => AdminOrderItem(
        orderId: map['order id']?.toString() ?? '',
        ordersId: map['orders id']?.toString() ?? '',
        orderStatus: map['order status'] as String? ?? '',
        productCategory: map['product category'] as String? ?? '',
        deliveryCategory: map['delivary category'] as String? ?? '',
        orderTime: map['order time']?.toString() ?? '',
        productId: map['product id']?.toString() ?? '',
        productNumber: (map['product number'] as num?)?.toInt() ?? 0,
        venderId: map['vender id']?.toString() ?? '',
        vendorName: map['vendor name']?.toString() ?? '',
        riderId: map['rider id']?.toString() ?? '',
        riderName: map['rider name']?.toString() ?? '',
        riderNumber: map['rider number']?.toString() ?? '',
        userName: map['user name']?.toString() ?? '',
        userNumber: map['user number']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
        orderId, ordersId, orderStatus, productCategory, deliveryCategory,
        orderTime, productId, productNumber, venderId, vendorName,
        riderId, riderName, riderNumber, userName, userNumber,
      ];
}
