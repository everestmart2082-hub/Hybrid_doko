import 'package:equatable/equatable.dart';

// ─── Rider List Item ─────────────────────────────────────────────────────────
// Server returns key: "rider id"

class AdminRiderItem extends Equatable {
  final String riderId;
  final String name;
  final List<dynamic> violations;
  final bool? status;         // maps "verified"
  final bool? updateRequest;  // maps "updateRequest"

  const AdminRiderItem({
    required this.riderId,
    required this.name,
    required this.violations,
    this.status,
    this.updateRequest,
  });

  factory AdminRiderItem.fromMap(Map<String, dynamic> map) => AdminRiderItem(
        riderId: map['rider id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        violations: (map['violations'] as List<dynamic>?) ?? [],
        status: map['status'] as bool?,
        updateRequest: map['updateRequest'] as bool?,
      );

  @override
  List<Object?> get props => [riderId, name, violations, status, updateRequest];
}

// ─── State Request ──────────────────────────────────────────────────────────
// Server reads: c.PostForm("rider id") + state field ("approved"|"suspended"|"blacklisted")

class AdminRiderStateRequest extends Equatable {
  final String riderId;
  final bool state;

  const AdminRiderStateRequest({required this.riderId, required this.state});

  Map<String, dynamic> toMap(String fieldName) => {
        'rider id': riderId,
        fieldName: state.toString(),
      };

  @override
  List<Object?> get props => [riderId, state];
}
