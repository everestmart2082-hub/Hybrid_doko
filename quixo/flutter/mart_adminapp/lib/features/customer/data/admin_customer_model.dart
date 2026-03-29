import 'package:equatable/equatable.dart';

// ─── User List Item ─────────────────────────────────────────────────────────
// Server returns key: "user id"

class AdminUserItem extends Equatable {
  final String userId;
  final String name;
  final List<dynamic> violations;
  final bool? status;         // maps "verified"
  final bool? updateRequest;  // maps "updateRequest"

  const AdminUserItem({
    required this.userId,
    required this.name,
    required this.violations,
    this.status,
    this.updateRequest,
  });

  factory AdminUserItem.fromMap(Map<String, dynamic> map) => AdminUserItem(
        userId: map['user id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        violations: (map['violations'] as List<dynamic>?) ?? [],
        status: map['status'] as bool?,
        updateRequest: map['updateRequest'] as bool?,
      );

  @override
  List<Object?> get props => [userId, name, violations, status, updateRequest];
}

// ─── State Request ──────────────────────────────────────────────────────────
// Server reads: c.PostForm("user id") + state field ("approved"|"suspended"|"blacklisted")

class AdminUserStateRequest extends Equatable {
  final String userId;
  final bool state;

  const AdminUserStateRequest({required this.userId, required this.state});

  Map<String, dynamic> toMap(String fieldName) => {
        'user id': userId,
        fieldName: state.toString(),
      };

  @override
  List<Object?> get props => [userId, state];
}
