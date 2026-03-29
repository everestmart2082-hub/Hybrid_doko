import 'package:equatable/equatable.dart';

abstract class AdminEmployeeState extends Equatable {
  const AdminEmployeeState();
  @override List<Object?> get props => [];
}

class AdminEmployeeInitial extends AdminEmployeeState {}
class AdminEmployeeLoading extends AdminEmployeeState {}

/// Employee added/updated — OTP needed to confirm.
class AdminEmployeeOtpRequired extends AdminEmployeeState {
  final String phone;
  const AdminEmployeeOtpRequired(this.phone);
  @override List<Object?> get props => [phone];
}

class AdminEmployeeActionSuccess extends AdminEmployeeState {
  final String message;
  const AdminEmployeeActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class AdminEmployeeFailed extends AdminEmployeeState {
  final String message;
  const AdminEmployeeFailed(this.message);
  @override List<Object?> get props => [message];
}
