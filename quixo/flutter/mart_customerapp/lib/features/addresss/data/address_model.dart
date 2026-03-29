import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String id;
  final String label; // Home, Work, Office
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final String phoneNumber;
  final String email;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.city,
    required this.state,
    required this.pincode,
    required this.landmark,
    required this.phoneNumber,
    required this.email,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json["address id"] ?? json["address_id"] ?? json["_id"] ?? "").toString(),
      label: json["label"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      pincode: json["pincode"] ?? "",
      landmark: json["landmark"] ?? "",
      phoneNumber: json["phone number"] ?? json["phone_number"] ?? "",
      email: json["email"] ?? "",
      isDefault: json["default"] ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [id, label, city, state, pincode, landmark, phoneNumber, email, isDefault];
}