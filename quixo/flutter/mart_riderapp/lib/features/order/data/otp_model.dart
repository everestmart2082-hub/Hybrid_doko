import 'package:equatable/equatable.dart';

class GenerateOtpModel extends Equatable {
  final String orderId;

  const GenerateOtpModel({required this.orderId});

  // Backend uses: c.PostForm("orders id")
  Map<String, dynamic> toJson() => {"orders id": orderId};

  @override
  List<Object?> get props => [orderId];
}

class DeliverOrderOtpModel extends Equatable {
  final String orderId;
  final String otp;

  const DeliverOrderOtpModel({required this.orderId, required this.otp});

  // Backend uses: c.PostForm("orders id") and c.PostForm("otp")
  Map<String, dynamic> toJson() => {"orders id": orderId, "otp": otp};

  @override
  List<Object?> get props => [orderId, otp];
}

class AcceptOrderModel extends Equatable {
  final String orderId;

  const AcceptOrderModel({required this.orderId});

  Map<String, dynamic> toJson() => {"orders id": orderId};

  @override
  List<Object?> get props => [orderId];
}

class RejectOrderModel extends Equatable {
  final String orderId;

  const RejectOrderModel({required this.orderId});

  Map<String, dynamic> toJson() => {"orders id": orderId};

  @override
  List<Object?> get props => [orderId];
}