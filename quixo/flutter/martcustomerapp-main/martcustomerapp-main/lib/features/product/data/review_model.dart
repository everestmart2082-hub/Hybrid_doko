import 'package:equatable/equatable.dart';

class ReviewRequestModel extends Equatable {
  final String productId;
  final String message;

  const ReviewRequestModel({
    required this.productId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "message": message,
    };
  }

  @override
  List<Object?> get props => [productId, message];
}