import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

/// Cross-platform picked file representation.
/// We use bytes so this model compiles on Flutter Web (no `dart:io`).
class RiderPickedFile {
  final Uint8List bytes;
  final String filename;

  const RiderPickedFile({
    required this.bytes,
    required this.filename,
  });

  MultipartFile toMultipartFile() {
    return MultipartFile.fromBytes(
      bytes,
      filename: filename,
    );
  }
}

class RiderRegistrationModel extends Equatable {
  final String name;
  final String number;
  final String email;
  final double rating;
  final RiderPickedFile rcBook;
  final RiderPickedFile citizenship;
  final RiderPickedFile panCard;
  final String address;
  final String bikeModel;
  final String bikeNumber;
  final String bikeColor;
  final String type; // bike / scooter
  final RiderPickedFile bikeInsurancePaper;

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
      "Rc Book file": rcBook.toMultipartFile(),
      "Citizenship file": citizenship.toMultipartFile(),
      "pan card file": panCard.toMultipartFile(),
      "Address": address,
      "bike model": bikeModel,
      "bike number": bikeNumber,
      "bike color": bikeColor,
      "type": type,
      "bike insurance paper file": bikeInsurancePaper.toMultipartFile(),
    });
  }

  @override
  List<Object?> get props => [
        name,
        number,
        email,
        rating,
        rcBook.filename,
        citizenship.filename,
        panCard.filename,
        address,
        bikeModel,
        bikeNumber,
        bikeColor,
        type,
        bikeInsurancePaper.filename,
      ];
}