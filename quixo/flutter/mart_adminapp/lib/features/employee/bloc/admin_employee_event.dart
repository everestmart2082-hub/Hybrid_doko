import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:mart_adminapp/features/employee/data/admin_employee_model.dart';

abstract class AdminEmployeeEvent extends Equatable {
  const AdminEmployeeEvent();
  @override List<Object?> get props => [];
}

class AdminEmployeeAdd extends AdminEmployeeEvent {
  final AdminEmployeeAddRequest req;
  final MultipartFile? citizenshipFile;
  const AdminEmployeeAdd({required this.req, this.citizenshipFile});
  @override List<Object?> get props => [req];
}

class AdminEmployeeUpdate extends AdminEmployeeEvent {
  final AdminEmployeeUpdateRequest req;
  final MultipartFile? citizenshipFile;
  const AdminEmployeeUpdate({required this.req, this.citizenshipFile});
  @override List<Object?> get props => [req];
}

class AdminEmployeeUpdateOtpVerify extends AdminEmployeeEvent {
  final String phone; final String otp;
  const AdminEmployeeUpdateOtpVerify({required this.phone, required this.otp});
  @override List<Object?> get props => [phone, otp];
}

class AdminEmployeeDelete extends AdminEmployeeEvent {
  final String employeeId;
  const AdminEmployeeDelete(this.employeeId);
  @override List<Object?> get props => [employeeId];
}

class AdminEmployeeUpdateViolations extends AdminEmployeeEvent {
  final String employeeId; final List<String> violations;
  const AdminEmployeeUpdateViolations({required this.employeeId, required this.violations});
  @override List<Object?> get props => [employeeId, violations];
}
