import 'dart:convert';
import 'package:equatable/equatable.dart';

class VenderAuthModel extends Equatable {
  final String name;
  final String number;
  final String pan;
  final String storeName;
  final String address;
  final String email;
  final String businessType;
  final String description;
  final String geolocation;

  const VenderAuthModel({
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

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "number": number,
      "pan": pan,
      "storeName": storeName,
      "address": address,
      "email": email,
      "businessType": businessType,
      "description": description,
      "geolocation": geolocation
    };
  }

  String toJson() => json.encode(toMap());
}