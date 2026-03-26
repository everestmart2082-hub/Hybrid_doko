import 'package:equatable/equatable.dart';

class RatingRequestModel extends Equatable {
  final String productId;
  final double rating;

  const RatingRequestModel({
    required this.productId,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "rating": rating,
    };
  }

  @override
  List<Object?> get props => [productId, rating];
}