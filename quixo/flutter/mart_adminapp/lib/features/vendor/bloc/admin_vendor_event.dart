import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/vendor/data/admin_vendor_model.dart';

abstract class AdminVendorEvent extends Equatable {
  const AdminVendorEvent();
  @override List<Object?> get props => [];
}

class AdminVendorLoad extends AdminVendorEvent {}

class AdminVendorApprove extends AdminVendorEvent {
  final String venderId;
  final bool approved;
  const AdminVendorApprove({required this.venderId, required this.approved});
  @override List<Object?> get props => [venderId, approved];
}

class AdminVendorSuspend extends AdminVendorEvent {
  final String venderId;
  final bool suspended;
  const AdminVendorSuspend({required this.venderId, required this.suspended});
  @override List<Object?> get props => [venderId, suspended];
}

class AdminVendorBlacklist extends AdminVendorEvent {
  final String venderId;
  final bool blacklisted;
  const AdminVendorBlacklist({required this.venderId, required this.blacklisted});
  @override List<Object?> get props => [venderId, blacklisted];
}

class AdminVendorNotify extends AdminVendorEvent {
  final AdminNotificationRequest req;
  const AdminVendorNotify(this.req);
  @override List<Object?> get props => [req];
}

class AdminVendorUpdateViolations extends AdminVendorEvent {
  final AdminViolationsRequest req;
  const AdminVendorUpdateViolations(this.req);
  @override List<Object?> get props => [req];
}
