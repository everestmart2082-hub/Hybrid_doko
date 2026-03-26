import 'package:equatable/equatable.dart';

class PaymentQueryModel extends Equatable {
  final String userId;
  final String paymentMethod;

  const PaymentQueryModel({
    required this.userId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toQuery() {
    return {
      "user_id": userId,
      "payment_method": paymentMethod,
    };
  }

  @override
  List<Object?> get props => [userId, paymentMethod];
}