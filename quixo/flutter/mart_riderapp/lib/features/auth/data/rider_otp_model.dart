import 'package:equatable/equatable.dart';

class RiderOtpModel extends Equatable {
  final String phone;
  final String otp;

  const RiderOtpModel({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "otp": otp,
    };
  }

  @override
  List<Object?> get props => [phone, otp];
}