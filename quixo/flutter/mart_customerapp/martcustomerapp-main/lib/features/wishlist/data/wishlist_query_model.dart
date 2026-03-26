import 'package:equatable/equatable.dart';

class WishlistQueryModel extends Equatable {
  final int page;
  final int limit;

  const WishlistQueryModel({this.page = 1, this.limit = 20});

  Map<String, dynamic> toJson() {
    return {
      "page": page,
      "limit": limit,
    };
  }

  @override
  List<Object?> get props => [page, limit];
}