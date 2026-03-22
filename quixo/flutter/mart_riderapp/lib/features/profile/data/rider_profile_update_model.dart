import 'package:equatable/equatable.dart';

class RiderProfileUpdateModel extends Equatable {
  final String number;
  final String? description;
  final String? defaultAddress;

  const RiderProfileUpdateModel({
    required this.number,
    this.description,
    this.defaultAddress,
  });

  Map<String, dynamic> toJson() => {
        "number": number,
        "description": description,
        "default address": defaultAddress,
      };

  @override
  List<Object?> get props => [number, description, defaultAddress];
}