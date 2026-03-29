import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

class SendMessageRequestModel extends Equatable {
  final String message;

  const SendMessageRequestModel({required this.message});

  FormData toFormData() {
    return FormData.fromMap({
      "message": message,
    });
  }

  @override
  List<Object?> get props => [message];
}

class ProductReviewRequestModel extends Equatable {
  final String productId;
  final String message;

  const ProductReviewRequestModel({
    required this.productId,
    required this.message,
  });

  FormData toFormData() {
    return FormData.fromMap({
      "product id": productId,
      "message": message,
    });
  }

  @override
  List<Object?> get props => [productId, message];
}

class ProductRatingRequestModel extends Equatable {
  final String productId;
  final int rating;

  const ProductRatingRequestModel({
    required this.productId,
    required this.rating,
  });

  FormData toFormData() {
    return FormData.fromMap({
      "product id": productId,
      "rating": rating.toString(),
    });
  }

  @override
  List<Object?> get props => [productId, rating];
}
