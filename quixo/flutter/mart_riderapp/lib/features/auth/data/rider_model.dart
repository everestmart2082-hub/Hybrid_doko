import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

class RiderRegistrationModel extends Equatable {
  final String name;
  final String number;
  final String email;
  final double rating;
  final File rcBook;
  final File citizenship;
  final File panCard;
  final String address;
  final String bikeModel;
  final String bikeNumber;
  final String bikeColor;
  final String type; // bike / scooter
  final File bikeInsurancePaper;

  const RiderRegistrationModel({
    required this.name,
    required this.number,
    required this.email,
    required this.rating,
    required this.rcBook,
    required this.citizenship,
    required this.panCard,
    required this.address,
    required this.bikeModel,
    required this.bikeNumber,
    required this.bikeColor,
    required this.type,
    required this.bikeInsurancePaper,
  });

  /// Convert to MultipartFormData for Dio
  Future<FormData> toFormData() async {
    return FormData.fromMap({
      "name": name,
      "number": number,
      "email": email,
      "rating": rating,
      "Rc Book": await MultipartFile.fromFile(rcBook.path, filename: rcBook.path.split("/").last),
      "Citizenship": await MultipartFile.fromFile(citizenship.path, filename: citizenship.path.split("/").last),
      "pan card": await MultipartFile.fromFile(panCard.path, filename: panCard.path.split("/").last),
      "Address": address,
      "bike model": bikeModel,
      "bike number": bikeNumber,
      "bike color": bikeColor,
      "type": type,
      "bike insurance paper": await MultipartFile.fromFile(bikeInsurancePaper.path, filename: bikeInsurancePaper.path.split("/").last),
    });
  }

  @override
  List<Object?> get props => [
        name,
        number,
        email,
        rating,
        rcBook,
        citizenship,
        panCard,
        address,
        bikeModel,
        bikeNumber,
        bikeColor,
        type,
        bikeInsurancePaper,
      ];
}