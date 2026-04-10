class ProductReviewRow {
  final String message;
  final String userName;
  final String dateStr;

  const ProductReviewRow({
    required this.message,
    required this.userName,
    required this.dateStr,
  });

  factory ProductReviewRow.fromMap(Map<String, dynamic> map) {
    return ProductReviewRow(
      message: map['message']?.toString() ?? '',
      userName: map['user name']?.toString() ?? '',
      dateStr: map['date']?.toString() ?? '',
    );
  }
}
