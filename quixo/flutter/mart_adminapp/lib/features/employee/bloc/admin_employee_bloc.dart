import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/employee/repository/admin_employee_remote.dart';
import 'admin_employee_event.dart';
import 'admin_employee_state.dart';

class AdminEmployeeBloc extends Bloc<AdminEmployeeEvent, AdminEmployeeState> {
  final AdminEmployeeRemote remote;

  AdminEmployeeBloc(this.remote) : super(AdminEmployeeInitial()) {
    on<AdminEmployeeAdd>(_onAdd);
    on<AdminEmployeeUpdate>(_onUpdate);
    on<AdminEmployeeUpdateOtpVerify>(_onOtpVerify);
    on<AdminEmployeeDelete>(_onDelete);
    on<AdminEmployeeUpdateViolations>(_onViolations);
  }

  FutureOr<void> _onAdd(AdminEmployeeAdd e, Emitter<AdminEmployeeState> emit) async {
    emit(AdminEmployeeLoading());
    try {
      await remote.addEmployee(e.req, citizenshipFile: e.citizenshipFile);
      // Server sends OTP to employee phone after add
      emit(AdminEmployeeOtpRequired(e.req.phone));
    } catch (ex) {
      emit(AdminEmployeeFailed(ex.toString()));
    }
  }

  FutureOr<void> _onUpdate(AdminEmployeeUpdate e, Emitter<AdminEmployeeState> emit) async {
    emit(AdminEmployeeLoading());
    try {
      await remote.updateEmployee(e.req, citizenshipFile: e.citizenshipFile);
      emit(AdminEmployeeOtpRequired(e.req.phone));
    } catch (ex) {
      emit(AdminEmployeeFailed(ex.toString()));
    }
  }

  FutureOr<void> _onOtpVerify(
      AdminEmployeeUpdateOtpVerify e, Emitter<AdminEmployeeState> emit) async {
    emit(AdminEmployeeLoading());
    try {
      await remote.verifyUpdateOtp(e.phone, e.otp);
      emit(const AdminEmployeeActionSuccess('Employee saved successfully.'));
    } catch (ex) {
      emit(AdminEmployeeFailed(ex.toString()));
    }
  }

  FutureOr<void> _onDelete(AdminEmployeeDelete e, Emitter<AdminEmployeeState> emit) async {
    emit(AdminEmployeeLoading());
    try {
      await remote.deleteEmployee(e.employeeId);
      emit(const AdminEmployeeActionSuccess('Employee deleted.'));
    } catch (ex) {
      emit(AdminEmployeeFailed(ex.toString()));
    }
  }

  FutureOr<void> _onViolations(
      AdminEmployeeUpdateViolations e, Emitter<AdminEmployeeState> emit) async {
    emit(AdminEmployeeLoading());
    try {
      await remote.updateViolations(e.employeeId, e.violations);
      emit(const AdminEmployeeActionSuccess('Violations updated.'));
    } catch (ex) {
      emit(AdminEmployeeFailed(ex.toString()));
    }
  }
}
