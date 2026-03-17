import 'package:equatable/equatable.dart';

class SimpleResponseModel extends Equatable {
  final bool success;
  final String message;

  const SimpleResponseModel({
    required this.success,
    required this.message,
  });

  factory SimpleResponseModel.fromJson(Map<String, dynamic> json) {
    return SimpleResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }

  @override
  List<Object?> get props => [success, message];
}