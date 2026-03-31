
import 'package:equatable/equatable.dart';

class RiderProfileResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? name;
  final String? number;
  final String? email;
  final String? defaultAddress;
  final String? bikeDetail;
  final bool? verified;
  final bool? updationRequested;
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
    this.verified,
    this.updationRequested,
    this.blueBookUrl,
    this.insurancePaperUrl,
    this.panCardUrl,
    this.citizenshipUrl,
  });

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return false;
  }

  factory RiderProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final msgRaw = json["message"];
    final msg = msgRaw is Map ? msgRaw.cast<String, dynamic>() : <String, dynamic>{};

    return RiderProfileResponseModel(
      success: json["success"] ?? false,
      message: msgRaw is String ? msgRaw : (json["message"]?.toString() ?? ""),
      // Server keys inside `message` map:
      // name, number, email, Rc Book file, Citizenship file, pan card file, Address, bike model, bike number, bike color, bike insurance paper file, type, ...
      name: msg["name"]?.toString(),
      number: msg["number"]?.toString(),
      email: msg["email"]?.toString(),
      defaultAddress: msg["Address"]?.toString(),
      bikeDetail: msg["bike model"]?.toString(),
      verified: _toBool(msg["verified"]),
      updationRequested: _toBool(msg["updation requested"]),
      blueBookUrl: msg["Rc Book file"]?.toString(),
      insurancePaperUrl: msg["bike insurance paper file"]?.toString(),
      panCardUrl: msg["pan card file"]?.toString(),
      citizenshipUrl: msg["Citizenship file"]?.toString(),
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
    verified,
    updationRequested,
        blueBookUrl,
        insurancePaperUrl,
        panCardUrl,
        citizenshipUrl,
      ];
}