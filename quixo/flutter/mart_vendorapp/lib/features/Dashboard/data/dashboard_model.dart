import 'package:equatable/equatable.dart';

class VendorChartData extends Equatable {
  final String label;
  final double value;

  const VendorChartData({required this.label, required this.value});

  factory VendorChartData.fromMap(Map<String, dynamic> map) {
    return VendorChartData(
      label: map["date"] ?? map["day"] ?? "",
      value: (map["amount"] ?? map["revenue"] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [label, value];
}

class DashboardStatsModel extends Equatable {
  final int totalOrders;
  final int preparingOrders;
  final int preparedOrders;
  final int deliveredOrders;
  final int cancelledByUserOrders;
  final int cancelledByVendorOrders;
  final int returnedOrders;

  final double totalRevenue;
  final List<VendorChartData> chart;

  final int totalProducts;
  final int outOfStockProducts;
  final int lowStockProducts;
  final int activeProducts;
  final int inactiveProducts;

  const DashboardStatsModel({
    required this.totalOrders,
    required this.preparingOrders,
    required this.preparedOrders,
    required this.deliveredOrders,
    required this.cancelledByUserOrders,
    required this.cancelledByVendorOrders,
    required this.returnedOrders,
    required this.totalRevenue,
    required this.chart,
    required this.totalProducts,
    required this.outOfStockProducts,
    required this.lowStockProducts,
    required this.activeProducts,
    required this.inactiveProducts,
  });

  @override
  List<Object?> get props => [
    totalOrders, preparingOrders, preparedOrders, deliveredOrders,
    cancelledByUserOrders, cancelledByVendorOrders, returnedOrders,
    totalRevenue, chart,
    totalProducts, outOfStockProducts, lowStockProducts, activeProducts, inactiveProducts
  ];
}