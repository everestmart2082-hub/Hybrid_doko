import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/core/utils/mongo_json.dart';

// ─── Vendor List Item ───────────────────────────────────────────────────────
// Server returns key: "vender id" (note the typo — kept to match server exactly)

class AdminVendorItem extends Equatable {
  final String venderId;
  final String name;
  final String number;
  final String email;
  final String panFile;
  final String storeName;
  final String address;
  final String businessType;
  final String description;
  final double revenue;
  final bool suspended;
  final List<dynamic> violations;
  final bool? status;       // maps "verified"
  final bool? updateRequest; // maps "updateRequest"
  /// Cumulative text from admin "Notify" (Mongo `message`).
  final String adminMessage;

  const AdminVendorItem({
    required this.venderId,
    required this.name,
    required this.number,
    required this.email,
    required this.panFile,
    required this.storeName,
    required this.address,
    required this.businessType,
    required this.description,
    required this.revenue,
    required this.suspended,
    required this.violations,
    this.status,
    this.updateRequest,
    this.adminMessage = '',
  });

  factory AdminVendorItem.fromMap(Map<String, dynamic> map) => AdminVendorItem(
        venderId: mongoIdToString(map['vender id'] ?? map['_id']),
        name: map['name'] as String? ?? '',
        number: map['number'] as String? ?? '',
        email: map['email'] as String? ?? '',
        panFile: dynamicToPlainString(map['pan_file']),
        storeName: map['store_name'] as String? ?? '',
        address: map['address'] as String? ?? '',
        businessType: map['business_type'] as String? ?? '',
        description: map['description'] as String? ?? '',
        revenue: num.tryParse(map['revenue']?.toString() ?? '')?.toDouble() ?? 0.0,
        suspended: map['suspended'] as bool? ?? false,
        violations: (map['violations'] as List<dynamic>?) ?? [],
        status: map['status'] as bool?,
        updateRequest: map['updateRequest'] as bool?,
        adminMessage: map['message']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
    venderId, name, number, email, panFile, storeName, address,
    businessType, description, revenue, suspended, violations, status, updateRequest,
    adminMessage,
  ];
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
