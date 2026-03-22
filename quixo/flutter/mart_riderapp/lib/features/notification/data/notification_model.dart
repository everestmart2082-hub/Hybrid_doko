import 'package:equatable/equatable.dart';

class RiderNotificationModel extends Equatable {
  final String message;
  final DateTime date;

  const RiderNotificationModel({
    required this.message,
    required this.date,
  });

  factory RiderNotificationModel.fromJson(Map<String, dynamic> json) {
    return RiderNotificationModel(
      message: json["message"] ?? "",
      date: DateTime.tryParse(json["date"] ?? "") ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [message, date];
}