import '../../../core/network/dio_client.dart';
import '../data/dashboard_model.dart';

class DashboardRemote {
  final DioClient dio;

  DashboardRemote({required this.dio});

  /// Get vendor chart data
  Future<VendorChartResponse> getVendorChart({
    int page = 1,
    int limit = 10,
  }) async {
    final map = await dio.post(
      "/api/vender/chart",
      {
        "page": page,
        "limit": limit,
      },
    );

    return VendorChartResponse.fromMap(map);
  }
}