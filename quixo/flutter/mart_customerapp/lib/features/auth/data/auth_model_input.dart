import 'dart:convert';

import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String phone;
  final String email;

  const AuthModel({
    required this.phone,
    required this.email,
  });


  @override
  List<Object> get props => [phone, email];

  AuthModel copyWith({
    String? phone,
    String? email,
  }) {
    return AuthModel(
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone': phone,
      'email': email,
    };
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthModel.fromJson(String source) => AuthModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
