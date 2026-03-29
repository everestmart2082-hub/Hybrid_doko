import 'package:quickmartvender/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../data/dashboard_model.dart';
import '../../Product/data/product_model.dart';
import '../../Order/data/order_model.dart';

class DashboardRemote {
  final DioClient dio;

  DashboardRemote({required this.dio});

  Future<DashboardStatsModel> getDashboardStats() async {
    // Fetch Chart Data
    final chartMap = await dio.post(ApiEndpoints.chartMonth, {
      "page": 1,
      "limit": 10,
    });
    
    List<VendorChartData> chartData = [];
    double totalRevenue = 0;
    if (chartMap["chart"] != null && chartMap["chart"] is Map) {
      final ch = chartMap["chart"] as Map<String, dynamic>;
      totalRevenue = (ch["revenue"] ?? 0).toDouble();
      chartData.add(VendorChartData(
        label: ch["day"] ?? "",
        value: totalRevenue,
      ));
    }

    // Fetch Orders Data
    final orderMap = await dio.post(ApiEndpoints.order, {"page": 1, "limit": 1000});
    List<VendorOrder> orders = [];
    if (orderMap["message"] != null && orderMap["message"] is List && orderMap["message"].length > 1) {
      orders = (orderMap["message"][1] as List).map((e) => VendorOrder.fromMap(e)).toList();
    }
    
    // Fetch Products Data
    final productMap = await dio.get(ApiEndpoints.products, query: {"page": 1, "limit": 1000});
    List<Product> products = [];
    if (productMap["message"] != null && productMap["message"] is List) {
      products = (productMap["message"] as List).map((e) => Product.fromMap(e)).toList();
    }

    // Compute Product Stats
    int outOfStock = 0, lowStock = 0, active = 0, inactive = 0;
    for (var p in products) {
      if (p.stock <= 0) outOfStock++;
      else if (p.stock < 5) lowStock++;
      
      if (p.stock > 0) active++; else inactive++;
    }

    // Compute Order Stats
    int preparing = 0, prepared = 0, delivered = 0, cancelUser = 0, cancelVendor = 0, returned = 0;
    for (var o in orders) {
      final s = o.orderStatus.toLowerCase();
      if (s.contains("preparing")) preparing++;
      else if (s.contains("prepared")) prepared++;
      else if (s.contains("delivered")) delivered++;
      else if (s.contains("cancelled by user") || s.contains("cancelbyuser")) cancelUser++;
      else if (s.contains("cancelled by vendor") || s.contains("cancelbyvendor")) cancelVendor++;
      else if (s.contains("returned")) returned++;
    }

    return DashboardStatsModel(
      totalOrders: orders.length,
      preparingOrders: preparing,
      preparedOrders: prepared,
      deliveredOrders: delivered,
      cancelledByUserOrders: cancelUser,
      cancelledByVendorOrders: cancelVendor,
      returnedOrders: returned,
      totalRevenue: totalRevenue,
      chart: chartData,
      totalProducts: products.length,
      outOfStockProducts: outOfStock,
      lowStockProducts: lowStock,
      activeProducts: active,
      inactiveProducts: inactive,
    );
  }
}
