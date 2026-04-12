import 'package:equatable/equatable.dart';

/// Row from MongoDB `notifications` collection (admin list API).
class AdminNotificationItem extends Equatable {
  final String id;
  final String type;
  final String message;
  final String targetId;
  final String date;
  final bool received;

  const AdminNotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.targetId,
    required this.date,
    required this.received,
  });

  factory AdminNotificationItem.fromMap(Map<String, dynamic> map) {
    final rec = map['received'];
    return AdminNotificationItem(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      targetId: map['target_id']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      received: rec == true ||
          rec == 1 ||
          rec?.toString().toLowerCase() == 'true',
    );
  }

  /// Contact tab: messages tied to people (vendor / rider / customer).
  static bool isContactType(String raw) {
    final t = raw.toLowerCase().trim();
    return t == 'vendor' || t == 'rider' || t == 'customer' || t == 'user';
  }

  bool get isContact => isContactType(type);

  bool get isOrder => type.toLowerCase().trim() == 'order';

  bool get isProduct => type.toLowerCase().trim() == 'product';

  /// Everything that is not contact, order, or product (e.g. miscellaneous, register).
  bool get isMiscellaneous =>
      !isContact && !isOrder && !isProduct;

  @override
  List<Object?> get props => [id, type, message, targetId, date, received];
}
