import 'package:equatable/equatable.dart';

class RiderDashboardModel extends Equatable {
  final double earning;
  final int deliveredOrders;
  final int ongoingOrders;

  const RiderDashboardModel({
    required this.earning,
    required this.deliveredOrders,
    required this.ongoingOrders,
  });

  factory RiderDashboardModel.fromJson(Map<String, dynamic> json) {
    return RiderDashboardModel(
      earning: (json["earning"] ?? 0).toDouble(),
      deliveredOrders: json["order delivered number"] ?? 0,
      ongoingOrders: json["order ongoing number"] ?? 0,
    );
  }

  @override
  List<Object?> get props => [earning, deliveredOrders, ongoingOrders];
}