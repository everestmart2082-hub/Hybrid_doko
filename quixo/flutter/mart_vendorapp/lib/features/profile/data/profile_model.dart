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
  /// Cumulative admin "Notify" text (from profile API `admin_message`).
  final String adminMessage;

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
    this.adminMessage = '',
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
        geolocation,
        adminMessage,
      ];

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    String s(dynamic v) => v?.toString() ?? '';
    return ProfileModel(
      name: s(map['name']),
      number: s(map['number']),
      pan: s(map['Pan file'] ?? map['pan_file'] ?? map['pan number']),
      storeName: s(map['storeName'] ?? map['store name'] ?? map['store_name']),
      address: s(map['Address'] ?? map['address']),
      email: s(map['email']),
      businessType: s(
          map['BusinessType'] ?? map['business type'] ?? map['business_type']),
      description: s(map['Description'] ?? map['description']),
      geolocation: s(map['geolocation']),
      adminMessage: s(map['admin_message']),
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