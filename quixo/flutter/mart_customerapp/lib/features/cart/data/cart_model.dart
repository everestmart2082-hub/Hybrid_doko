import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

class CartAddRequestModel extends Equatable {
  final String productId;
  final int number;

  const CartAddRequestModel({
    required this.productId,
    required this.number,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "number": number,
    };
  }

  FormData toFormData() {
    return FormData.fromMap({
      "product id": productId,
      "number": number.toString(),
    });
  }

  @override
  List<Object?> get props => [productId, number];
}