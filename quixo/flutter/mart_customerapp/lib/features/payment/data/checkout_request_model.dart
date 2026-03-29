import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

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

  FormData toFormData() {
    var formData = FormData.fromMap({
      "address id": addressId,
      "payment method": paymentMethod,
    });
    // Add array elements as list
    for (var i = 0; i < cartIds.length; i++) {
      formData.fields.add(MapEntry("cart ids[]", cartIds[i]));
    }
    return formData;
  }

  @override
  List<Object?> get props => [addressId, cartIds, paymentMethod];
}