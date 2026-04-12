import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/core/utils/mongo_json.dart';

// ─── Rider List Item ─────────────────────────────────────────────────────────
// Server returns key: "rider id"

class AdminRiderItem extends Equatable {
  final String riderId;
  final String name;
  final String number;
  final String email;
  final double rating;
  final String rcBookFile;
  final String citizenshipFile;
  final String panCardFile;
  final String address;
  final String bikeModel;
  final String bikeNumber;
  final String bikeColor;
  final String type;
  final String bikeInsuranceFile;
  final bool suspended;
  final double revenue;
  final List<dynamic> violations;
  final bool? status;         // maps "verified"
  final bool? updateRequest;  // maps "updateRequest"
  /// Cumulative text from admin "Notify" (Mongo `message`).
  final String adminMessage;

  const AdminRiderItem({
    required this.riderId,
    required this.name,
    required this.number,
    required this.email,
    required this.rating,
    required this.rcBookFile,
    required this.citizenshipFile,
    required this.panCardFile,
    required this.address,
    required this.bikeModel,
    required this.bikeNumber,
    required this.bikeColor,
    required this.type,
    required this.bikeInsuranceFile,
    required this.suspended,
    required this.revenue,
    required this.violations,
    this.status,
    this.updateRequest,
    this.adminMessage = '',
  });

  factory AdminRiderItem.fromMap(Map<String, dynamic> map) => AdminRiderItem(
        riderId: mongoIdToString(map['rider id'] ?? map['_id']),
        name: map['name'] as String? ?? '',
        number: map['number'] as String? ?? '',
        email: map['email'] as String? ?? '',
        rating: num.tryParse(map['rating']?.toString() ?? '')?.toDouble() ?? 0.0,
        rcBookFile: dynamicToPlainString(map['rc_book_file']),
        citizenshipFile: dynamicToPlainString(map['citizenship_file']),
        panCardFile: dynamicToPlainString(map['pan_card_file']),
        address: map['address'] as String? ?? '',
        bikeModel: map['bike_model'] as String? ?? '',
        bikeNumber: map['bike_number'] as String? ?? '',
        bikeColor: map['bike_color'] as String? ?? '',
        type: map['type'] as String? ?? '',
        bikeInsuranceFile: dynamicToPlainString(map['bike_insurance_paper_file']),
        suspended: map['suspended'] as bool? ?? false,
        revenue: num.tryParse(map['revenue']?.toString() ?? '')?.toDouble() ?? 0.0,
        violations: (map['violations'] as List<dynamic>?) ?? [],
        status: map['status'] as bool?,
        updateRequest: map['updateRequest'] as bool?,
        adminMessage: map['message']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [
    riderId, name, number, email, rating, rcBookFile, citizenshipFile,
    panCardFile, address, bikeModel, bikeNumber, bikeColor, type,
    bikeInsuranceFile, suspended, revenue, violations, status, updateRequest,
    adminMessage,
  ];
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
