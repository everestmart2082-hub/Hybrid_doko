import 'package:equatable/equatable.dart';

// ─── Vendor List Item ───────────────────────────────────────────────────────
// Server returns key: "vender id" (note the typo — kept to match server exactly)

class AdminVendorItem extends Equatable {
  final String venderId;
  final String name;
  final List<dynamic> violations;
  final bool? status;       // maps "verified"
  final bool? updateRequest; // maps "updateRequest"

  const AdminVendorItem({
    required this.venderId,
    required this.name,
    required this.violations,
    this.status,
    this.updateRequest,
  });

  factory AdminVendorItem.fromMap(Map<String, dynamic> map) => AdminVendorItem(
        venderId: map['vender id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        violations: (map['violations'] as List<dynamic>?) ?? [],
        status: map['status'] as bool?,
        updateRequest: map['updateRequest'] as bool?,
      );

  @override
  List<Object?> get props => [venderId, name, violations, status, updateRequest];
}

// ─── Approve / Suspend / Blacklist Request ──────────────────────────────────
// Server reads: c.PostForm("vender id") + c.PostForm("approved"|"suspended"|"blacklisted")

class AdminVendorStateRequest extends Equatable {
  final String venderId;
  final bool state;

  const AdminVendorStateRequest({required this.venderId, required this.state});

  // fieldName is the server's expected form field (e.g. "approved")
  Map<String, dynamic> toMap(String fieldName) => {
        'vender id': venderId,
        fieldName: state.toString(),
      };

  @override
  List<Object?> get props => [venderId, state];
}

// ─── Notification Request ───────────────────────────────────────────────────
// Server reads: c.PostForm("vender id"), c.PostForm("message")

class AdminNotificationRequest extends Equatable {
  final String targetId;
  final String message;

  const AdminNotificationRequest({
    required this.targetId,
    required this.message,
  });

  @override
  List<Object?> get props => [targetId, message];
}

// ─── Violations Update Request ──────────────────────────────────────────────
// Server reads: c.PostFormArray("violations[]")

class AdminViolationsRequest extends Equatable {
  final String targetId;
  final List<String> violations;

  const AdminViolationsRequest({
    required this.targetId,
    required this.violations,
  });

  @override
  List<Object?> get props => [targetId, violations];
}
