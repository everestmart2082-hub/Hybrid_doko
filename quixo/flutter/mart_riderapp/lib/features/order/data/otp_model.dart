import 'package:equatable/equatable.dart';

class GenerateOtpModel extends Equatable {
  final String orderId;

  const GenerateOtpModel({required this.orderId});

  Map<String, dynamic> toJson() => {"order id": orderId};

  @override
  List<Object?> get props => [orderId];
}

class DeliverOrderOtpModel extends Equatable {
  final String orderId;
  final String otp;

  const DeliverOrderOtpModel({required this.orderId, required this.otp});

  Map<String, dynamic> toJson() => {"otp": otp};

  @override
  List<Object?> get props => [orderId, otp];
}