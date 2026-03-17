import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [productId, number];
}