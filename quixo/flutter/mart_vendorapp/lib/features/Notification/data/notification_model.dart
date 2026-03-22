import 'dart:convert';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {

  final String message;
  final String date;

  const NotificationModel({
    required this.message,
    required this.date,
  });

  @override
  List<Object?> get props => [message, date];

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      message: map["message"] ?? "",
      date: map["date"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "date": date,
    };
  }

  String toJson() => json.encode(toMap());

}