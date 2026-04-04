import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/customer/repository/admin_customer_remote.dart';
import 'admin_customer_event.dart';
import 'admin_customer_state.dart';

class AdminCustomerBloc extends Bloc<AdminCustomerEvent, AdminCustomerState> {
  final AdminCustomerRemote remote;

  AdminCustomerBloc(this.remote) : super(AdminCustomerInitial()) {
    on<AdminCustomerLoad>(_onLoad);
    on<AdminCustomerApprove>(_onApprove);
    on<AdminCustomerSuspend>(_onSuspend);
    on<AdminCustomerBlacklist>(_onBlacklist);
    on<AdminCustomerNotify>(_onNotify);
    on<AdminCustomerUpdateViolations>(_onViolations);
  }

  FutureOr<void> _onLoad(AdminCustomerLoad _, Emitter<AdminCustomerState> emit) async {
    emit(AdminCustomerLoading());
    try {
      emit(AdminCustomerLoaded(await remote.getAllUsers()));
    } catch (e) {
      emit(AdminCustomerFailed(e.toString()));
    }
  }

  FutureOr<void> _withReload(Future<void> Function() action,
      Emitter<AdminCustomerState> emit, {String success = 'Done'}) async {
    emit(AdminCustomerLoading());
    try {
      await action();
      emit(AdminCustomerActionSuccess(success));
      emit(AdminCustomerLoaded(await remote.getAllUsers()));
    } catch (e) {
      emit(AdminCustomerFailed(e.toString()));
    }
  }

  FutureOr<void> _onApprove(AdminCustomerApprove e, Emitter<AdminCustomerState> emit) =>
      _withReload(() => remote.approveUser(e.userId, e.approved), emit,
          success: 'User approval updated.');

  FutureOr<void> _onSuspend(AdminCustomerSuspend e, Emitter<AdminCustomerState> emit) =>
      _withReload(() => remote.suspendUser(e.userId, e.suspended), emit,
          success: 'User suspension updated.');

  FutureOr<void> _onBlacklist(AdminCustomerBlacklist e, Emitter<AdminCustomerState> emit) =>
      _withReload(() => remote.blacklistUser(e.userId, e.blacklisted), emit,
          success: 'User blacklist updated.');

  FutureOr<void> _onNotify(AdminCustomerNotify e, Emitter<AdminCustomerState> emit) =>
      _withReload(() => remote.sendNotification(e.userId, e.message), emit,
          success: 'Notification sent.');

  FutureOr<void> _onViolations(
      AdminCustomerUpdateViolations e, Emitter<AdminCustomerState> emit) =>
      _withReload(() => remote.updateViolations(e.userId, e.violations), emit,
          success: 'Violations updated.');
}
