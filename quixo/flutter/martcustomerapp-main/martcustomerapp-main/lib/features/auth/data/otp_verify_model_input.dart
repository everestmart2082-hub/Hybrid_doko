import 'dart:convert';

import 'package:equatable/equatable.dart';

class OtpVerifyModel extends Equatable {
  final String otp;
  final String phone;

  const OtpVerifyModel({
    required this.otp,
    required this.phone,
  });
  
  
  @override
  List<Object> get props => [otp, phone];
  

  OtpVerifyModel copyWith({
    String? otp,
    String? phone,
  }) {
    return OtpVerifyModel(
      otp: otp ?? this.otp,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'otp': otp,
      'phone': phone,
    };
  }

  factory OtpVerifyModel.fromMap(Map<String, dynamic> map) {
    return OtpVerifyModel(
      otp: map['otp'] as String,
      phone: map['phone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OtpVerifyModel.fromJson(String source) => OtpVerifyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
