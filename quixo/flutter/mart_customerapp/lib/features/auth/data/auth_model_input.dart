import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String phone;
  final String email;
  final String? name;

  const AuthModel({
    required this.phone,
    required this.email,
    this.name,
  });


  @override
  List<Object?> get props => [phone, email, name];

  AuthModel copyWith({
    String? phone,
    String? email,
    String? name,
  }) {
    return AuthModel(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone': phone,
      'email': email,
      'name': name,
    };
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      phone: map['phone'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  FormData toFormData() {
    return FormData.fromMap({
      'phone number': phone,
      'email': email,
      if (name != null) 'name': name,
    });
  }

  factory AuthModel.fromJson(String source) => AuthModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
