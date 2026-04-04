import 'dart:convert';
import 'package:equatable/equatable.dart';

class VenderOtpVerifyModel extends Equatable {
  final String otp;
  final String phone;

  const VenderOtpVerifyModel({
    required this.otp,
    required this.phone,
  });

  @override
  List<Object> get props => [otp, phone];

  Map<String, dynamic> toMap() {
    return {
      "otp": otp.trim(),
      "phone": phone.trim(),
    };
  }

  String toJson() => json.encode(toMap());

  factory VenderOtpVerifyModel.fromJson(String source) =>
      VenderOtpVerifyModel.fromMap(json.decode(source));

  factory VenderOtpVerifyModel.fromMap(Map<String, dynamic> map) {
    return VenderOtpVerifyModel(
      otp: map["otp"],
      phone: map["phone"],
    );
  }
}