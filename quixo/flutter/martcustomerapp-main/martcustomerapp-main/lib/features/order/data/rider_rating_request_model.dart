import 'package:equatable/equatable.dart';

class RiderRatingRequestModel extends Equatable {
  final String riderId;
  final double rating;

  const RiderRatingRequestModel({
    required this.riderId,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      "rider_id": riderId,
      "rating": rating,
    };
  }

  @override
  List<Object?> get props => [riderId, rating];
}