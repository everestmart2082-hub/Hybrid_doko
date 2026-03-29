import 'package:equatable/equatable.dart';

abstract class AdminRiderEvent extends Equatable {
  const AdminRiderEvent();
  @override List<Object?> get props => [];
}

class AdminRiderLoad extends AdminRiderEvent {}

class AdminRiderApprove extends AdminRiderEvent {
  final String riderId; final bool approved;
  const AdminRiderApprove({required this.riderId, required this.approved});
  @override List<Object?> get props => [riderId, approved];
}

class AdminRiderSuspend extends AdminRiderEvent {
  final String riderId; final bool suspended;
  const AdminRiderSuspend({required this.riderId, required this.suspended});
  @override List<Object?> get props => [riderId, suspended];
}

class AdminRiderBlacklist extends AdminRiderEvent {
  final String riderId; final bool blacklisted;
  const AdminRiderBlacklist({required this.riderId, required this.blacklisted});
  @override List<Object?> get props => [riderId, blacklisted];
}

class AdminRiderNotify extends AdminRiderEvent {
  final String riderId; final String message;
  const AdminRiderNotify({required this.riderId, required this.message});
  @override List<Object?> get props => [riderId, message];
}

class AdminRiderUpdateViolations extends AdminRiderEvent {
  final String riderId; final List<String> violations;
  const AdminRiderUpdateViolations({required this.riderId, required this.violations});
  @override List<Object?> get props => [riderId, violations];
}
