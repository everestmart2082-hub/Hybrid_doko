import 'package:equatable/equatable.dart';

class ProductReviewItem extends Equatable {
  final String message;
  final String userName;
  final String dateStr;

  const ProductReviewItem({
    required this.message,
    required this.userName,
    required this.dateStr,
  });

  factory ProductReviewItem.fromMap(Map<String, dynamic> map) {
    return ProductReviewItem(
      message: map['message']?.toString() ?? '',
      userName: map['user name']?.toString() ?? '',
      dateStr: map['date']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [message, userName, dateStr];
}
