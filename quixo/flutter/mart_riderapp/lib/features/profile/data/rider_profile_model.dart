import 'package:equatable/equatable.dart';

class RiderProfileModel extends Equatable {
  final String name;
  final String number;
  final String? email;
  final String? defaultAddress;
  final String? blueBookUrl;
  final String? bikeDetail;
  final String? insurancePaperUrl;
  final String? panCardUrl;
  final String? citizenshipUrl;
  final bool verified;
  final bool updationRequested;

  const RiderProfileModel({
    required this.name,
    required this.number,
    this.email,
    this.defaultAddress,
    this.blueBookUrl,
    this.bikeDetail,
    this.insurancePaperUrl,
    this.panCardUrl,
    this.citizenshipUrl,
    this.verified = false,
    this.updationRequested = false,
  });

  @override
  List<Object?> get props => [
        name,
        number,
        email,
        defaultAddress,
        blueBookUrl,
        bikeDetail,
        insurancePaperUrl,
        panCardUrl,
        citizenshipUrl,
        verified,
        updationRequested,
      ];
}