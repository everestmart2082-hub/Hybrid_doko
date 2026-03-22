import 'package:equatable/equatable.dart';

class RiderAuthResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? token;

  const RiderAuthResponseModel({
    required this.success,
    required this.message,
    this.token,
  });

  factory RiderAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return RiderAuthResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      token: json["token"],
    );
  }

  @override
  List<Object?> get props => [success, message, token];
}