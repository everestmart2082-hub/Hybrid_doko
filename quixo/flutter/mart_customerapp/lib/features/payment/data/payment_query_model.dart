import 'package:equatable/equatable.dart';

class PaymentQueryModel extends Equatable {
  final String paymentMethod;

  const PaymentQueryModel({
    required this.paymentMethod,
  });

  Map<String, dynamic> toQuery() {
    return {
      "payment method": paymentMethod,
    };
  }

  @override
  List<Object?> get props => [paymentMethod];
}