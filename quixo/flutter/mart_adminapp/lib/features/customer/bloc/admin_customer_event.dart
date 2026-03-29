import 'package:equatable/equatable.dart';

abstract class AdminCustomerEvent extends Equatable {
  const AdminCustomerEvent();
  @override List<Object?> get props => [];
}

class AdminCustomerLoad extends AdminCustomerEvent {}

class AdminCustomerApprove extends AdminCustomerEvent {
  final String userId; final bool approved;
  const AdminCustomerApprove({required this.userId, required this.approved});
  @override List<Object?> get props => [userId, approved];
}

class AdminCustomerSuspend extends AdminCustomerEvent {
  final String userId; final bool suspended;
  const AdminCustomerSuspend({required this.userId, required this.suspended});
  @override List<Object?> get props => [userId, suspended];
}

class AdminCustomerBlacklist extends AdminCustomerEvent {
  final String userId; final bool blacklisted;
  const AdminCustomerBlacklist({required this.userId, required this.blacklisted});
  @override List<Object?> get props => [userId, blacklisted];
}

class AdminCustomerNotify extends AdminCustomerEvent {
  final String userId; final String message;
  const AdminCustomerNotify({required this.userId, required this.message});
  @override List<Object?> get props => [userId, message];
}

class AdminCustomerUpdateViolations extends AdminCustomerEvent {
  final String userId; final List<String> violations;
  const AdminCustomerUpdateViolations({required this.userId, required this.violations});
  @override List<Object?> get props => [userId, violations];
}
