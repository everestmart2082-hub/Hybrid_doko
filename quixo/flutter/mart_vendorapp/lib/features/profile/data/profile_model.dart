import 'dart:convert';
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {

  final String name;
  final String number;
  final String pan;
  final String storeName;
  final String address;
  final String email;
  final String businessType;
  final String description;
  final String geolocation;

  const ProfileModel({
    required this.name,
    required this.number,
    required this.pan,
    required this.storeName,
    required this.address,
    required this.email,
    required this.businessType,
    required this.description,
    required this.geolocation,
  });

  @override
  List<Object?> get props => [
        name,
        number,
        pan,
        storeName,
        address,
        email,
        businessType,
        description,
        geolocation
      ];

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map["name"] ?? "",
      number: map["number"] ?? "",
      pan: map["pan"] ?? "",
      storeName: map["store_name"] ?? "",
      address: map["address"] ?? "",
      email: map["email"] ?? "",
      businessType: map["business_type"] ?? "",
      description: map["description"] ?? "",
      geolocation: map["geolocation"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "number": number,
      "address": address,
      "description": description,
      "geolocation": geolocation,
    };
  }

  String toJson() => json.encode(toMap());
}