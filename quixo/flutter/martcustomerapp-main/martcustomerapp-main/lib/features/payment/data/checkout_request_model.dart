import 'package:equatable/equatable.dart';

class CheckoutRequestModel extends Equatable {
  final String addressId;
  final List<String> cartIds;
  final String paymentMethod;

  const CheckoutRequestModel({
    required this.addressId,
    required this.cartIds,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      "address_id": addressId,
      "cart_ids": cartIds,
      "payment_method": paymentMethod,
    };
  }

  @override
  List<Object?> get props => [addressId, cartIds, paymentMethod];
}