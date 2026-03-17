import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String message;
  final String date;

  const NotificationModel({
    required this.message,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json["message"] ?? "",
      date: json["date"] ?? "",
    );
  }

  @override
  List<Object?> get props => [message, date];
}