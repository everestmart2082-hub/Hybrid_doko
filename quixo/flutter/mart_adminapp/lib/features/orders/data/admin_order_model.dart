import 'package:equatable/equatable.dart';

// ─── Order List Item ─────────────────────────────────────────────────────────
// Maps AdminOrderAll server response keys (spaced/lowercased, with typos)

class AdminOrderItem extends Equatable {
  final String orderId;
  final String orderStatus;
  final String productCategory;
  final String deliveryCategory;  // server key: "delivary category" (typo preserved)
  final String orderTime;         // server key: "order time"
  final String productId;
  final String venderId;          // server key: "vender id" (typo preserved)

  const AdminOrderItem({
    required this.orderId,
    required this.orderStatus,
    required this.productCategory,
    required this.deliveryCategory,
    required this.orderTime,
    required this.productId,
    required this.venderId,
  });

  factory AdminOrderItem.fromMap(Map<String, dynamic> map) => AdminOrderItem(
        orderId: map['order id']?.toString() ?? '',
        orderStatus: map['order status'] as String? ?? '',
        productCategory: map['product category'] as String? ?? '',
        deliveryCategory: map['delivary category'] as String? ?? '',
        orderTime: map['order time']?.toString() ?? '',
        productId: map['product id']?.toString() ?? '',
        venderId: map['vender id']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
        orderId, orderStatus, productCategory, deliveryCategory,
        orderTime, productId, venderId,
      ];
}
