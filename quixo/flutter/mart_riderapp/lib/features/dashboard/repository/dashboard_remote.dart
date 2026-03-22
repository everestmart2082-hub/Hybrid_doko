
import 'package:quickmartrider/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../data/dashboard_model.dart';

class RiderDashboardRemote {
  final DioClient dio;

  RiderDashboardRemote({required this.dio});

  Future<RiderDashboardModel> fetchDashboard() async {
    final response = await dio.post(
      ApiEndpoints.dashboard,
      {}
    );

    if (response.data["success"] == true) {
      return RiderDashboardModel.fromJson(response.data);
    } else {
      throw Exception(response.data["message"] ?? "Failed to fetch dashboard");
    }
  }
}