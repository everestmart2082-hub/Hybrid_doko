import 'package:equatable/equatable.dart';

class AddressRequestModel extends Equatable {
  final String? addressId;
  final String label;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final String phoneNumber;
  final String email;
  final bool? isDefault;

  const AddressRequestModel({
    this.addressId,
    required this.label,
    required this.city,
    required this.state,
    required this.pincode,
    required this.landmark,
    required this.phoneNumber,
    required this.email,
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) "address_id": addressId,
      "label": label,
      "city": city,
      "state": state,
      "pincode": pincode,
      "landmark": landmark,
      "phone_number": phoneNumber,
      "email": email,
      if (isDefault != null) "default": isDefault,
    };
  }

  @override
  List<Object?> get props =>
      [addressId, label, city, state, pincode, landmark, phoneNumber, email, isDefault];
}