
import 'package:equatable/equatable.dart';

class RiderProfileResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? name;
  final String? number;
  final String? email;
  final String? defaultAddress;
  final String? bikeDetail;
  final String? blueBookUrl;
  final String? insurancePaperUrl;
  final String? panCardUrl;
  final String? citizenshipUrl;

  const RiderProfileResponseModel({
    required this.success,
    required this.message,
    this.name,
    this.number,
    this.email,
    this.defaultAddress,
    this.bikeDetail,
    this.blueBookUrl,
    this.insurancePaperUrl,
    this.panCardUrl,
    this.citizenshipUrl,
  });

  factory RiderProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return RiderProfileResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      name: json["name"],
      number: json["number"],
      email: json["email"],
      defaultAddress: json["default address"],
      bikeDetail: json["bike detail"],
      blueBookUrl: json["blue book"],
      insurancePaperUrl: json["insurance paper"],
      panCardUrl: json["pan card"],
      citizenshipUrl: json["citizenship"],
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        name,
        number,
        email,
        defaultAddress,
        bikeDetail,
        blueBookUrl,
        insurancePaperUrl,
        panCardUrl,
        citizenshipUrl,
      ];
}