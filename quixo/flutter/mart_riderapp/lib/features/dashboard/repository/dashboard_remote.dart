
import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../data/dashboard_model.dart';

class RiderDashboardRemote {
  final DioClient dio;

  RiderDashboardRemote({required this.dio});

  Future<RiderDashboardModel> fetchDashboard() async {
    final response = await dio.post(
      ApiEndpoints.dashboard,
      FormData.fromMap({}),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data["success"] == true) {
      return RiderDashboardModel.fromJson(
        data["message"] as Map<String, dynamic>,
      );
    } else {
      throw Exception(data["message"] ?? "Failed to fetch dashboard");
    }
  }
}