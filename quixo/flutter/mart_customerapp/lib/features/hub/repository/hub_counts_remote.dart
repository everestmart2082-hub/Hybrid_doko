import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/dio_client.dart';

class CustomerHubCounts {
  final int cartItems;
  final int wishlist;
  final int openOrders;

  const CustomerHubCounts({
    required this.cartItems,
    required this.wishlist,
    required this.openOrders,
  });

  factory CustomerHubCounts.fromMap(Map<String, dynamic> m) {
    int n(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return CustomerHubCounts(
      cartItems: n(m['cart_items']),
      wishlist: n(m['wishlist']),
      openOrders: n(m['open_orders']),
    );
  }
}

class HubCountsRemote {
  final DioClient dio;

  HubCountsRemote({required this.dio});

  Future<CustomerHubCounts> getCounts() async {
    final raw = await dio.get(ApiEndpoints.userHubCounts);
    final map = Map<String, dynamic>.from(raw as Map);
    checkSuccess(map);
    final msg = map['message'];
    if (msg is! Map) {
      throw Exception('Invalid hub counts response');
    }
    return CustomerHubCounts.fromMap(Map<String, dynamic>.from(msg));
  }
}
