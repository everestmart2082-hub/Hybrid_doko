import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProfileOtpModel extends Equatable {
  final String otp;
  final String phone;

  const ProfileOtpModel({
    required this.otp,
    required this.phone,
  });

  @override
  List<Object> get props => [otp, phone];

  Map<String, dynamic> toMap() {
    return {
      "otp": otp,
      "phone": phone,
    };
  }

  String toJson() => json.encode(toMap());

  factory ProfileOtpModel.fromJson(String source) =>
      ProfileOtpModel.fromMap(json.decode(source));

  factory ProfileOtpModel.fromMap(Map<String, dynamic> map) {
    return ProfileOtpModel(
      otp: map["otp"],
      phone: map["phone"],
    );
  }
}