import 'package:equatable/equatable.dart';

class VendorChartData extends Equatable {
  final String label; // e.g., date or category
  final double value; // e.g., sales amount, order count

  const VendorChartData({
    required this.label,
    required this.value,
  });

  factory VendorChartData.fromMap(Map<String, dynamic> map) {
    return VendorChartData(
      label: map["label"] ?? "",
      value: (map["value"] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [label, value];
}

class VendorChartResponse {
  final bool success;
  final String message;
  final List<VendorChartData> data;

  VendorChartResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VendorChartResponse.fromMap(Map<String, dynamic> map) {
    final List<VendorChartData> chartData = [];
    if (map["message"] != null && map["message"] is List) {
      for (var e in map["message"]) {
        chartData.add(VendorChartData.fromMap(e));
      }
    }

    return VendorChartResponse(
      success: map["success"] ?? false,
      message: map["message"] is String ? map["message"] : "Chart loaded",
      data: chartData,
    );
  }
}