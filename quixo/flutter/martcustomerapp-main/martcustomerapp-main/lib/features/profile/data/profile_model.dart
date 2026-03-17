import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String name;
  final String phone;
  final String email;
  final String defaultAddress;
  final String description;

  const ProfileModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.defaultAddress,
    required this.description,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        email,
        defaultAddress,
        description,
      ];

  ProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? defaultAddress,
    String? description,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "default_address": defaultAddress,
      "description": description,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map["name"] ?? "",
      phone: map["number"] ?? "",
      email: map["email"] ?? "",
      defaultAddress: map["default_address"] ?? "",
      description: map["description"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source));
}