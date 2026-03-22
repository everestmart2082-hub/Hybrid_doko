import 'dart:io';
import 'package:equatable/equatable.dart';

class RiderProfileModel extends Equatable {
  final String name;
  final String number;
  final String? email;
  final String? defaultAddress;
  final File? blueBook;
  final String? bikeDetail;
  final File? insurancePaper;
  final File? panCard;
  final File? citizenship;

  const RiderProfileModel({
    required this.name,
    required this.number,
    this.email,
    this.defaultAddress,
    this.blueBook,
    this.bikeDetail,
    this.insurancePaper,
    this.panCard,
    this.citizenship,
  });

  @override
  List<Object?> get props => [
        name,
        number,
        email,
        defaultAddress,
        blueBook,
        bikeDetail,
        insurancePaper,
        panCard,
        citizenship,
      ];
}