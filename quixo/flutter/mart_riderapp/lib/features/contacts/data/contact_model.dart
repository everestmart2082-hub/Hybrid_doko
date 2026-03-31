import 'package:equatable/equatable.dart';

class RiderContactMessageModel extends Equatable {
  final String name;
  final String email;
  final String message;

  const RiderContactMessageModel({
    required this.name,
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [name, email, message];
}

class RiderContactResponseModel extends Equatable {
  final bool success;
  final String message;

  const RiderContactResponseModel({
    required this.success,
    required this.message,
  });

  factory RiderContactResponseModel.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] ?? json['success'];
    final success = switch (statusVal) {
      final bool b => b,
      final String s => s.toLowerCase() == 'true' || s == '1',
      final num n => n != 0,
      _ => false,
    };

    return RiderContactResponseModel(
      success: success,
      message: json['message']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [success, message];
}

