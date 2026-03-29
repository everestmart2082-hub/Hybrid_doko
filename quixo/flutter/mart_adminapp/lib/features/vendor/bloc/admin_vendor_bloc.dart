import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/vendor/repository/admin_vendor_remote.dart';
import 'admin_vendor_event.dart';
import 'admin_vendor_state.dart';

class AdminVendorBloc extends Bloc<AdminVendorEvent, AdminVendorState> {
  final AdminVendorRemote remote;

  AdminVendorBloc(this.remote) : super(AdminVendorInitial()) {
    on<AdminVendorLoad>(_onLoad);
    on<AdminVendorApprove>(_onApprove);
    on<AdminVendorSuspend>(_onSuspend);
    on<AdminVendorBlacklist>(_onBlacklist);
    on<AdminVendorNotify>(_onNotify);
    on<AdminVendorUpdateViolations>(_onViolations);
  }

  FutureOr<void> _onLoad(AdminVendorLoad _, Emitter<AdminVendorState> emit) async {
    emit(AdminVendorLoading());
    try {
      emit(AdminVendorLoaded(await remote.getAllVendors()));
    } catch (e) {
      emit(AdminVendorFailed(e.toString()));
    }
  }

  FutureOr<void> _withReload(
      Future<void> Function() action, Emitter<AdminVendorState> emit,
      {String success = 'Done'}) async {
    emit(AdminVendorLoading());
    try {
      await action();
      emit(AdminVendorActionSuccess(success));
      emit(AdminVendorLoaded(await remote.getAllVendors()));
    } catch (e) {
      emit(AdminVendorFailed(e.toString()));
    }
  }

  FutureOr<void> _onApprove(AdminVendorApprove e, Emitter<AdminVendorState> emit) =>
      _withReload(() => remote.approveVendor(e.venderId, e.approved), emit,
          success: 'Vendor approval updated.');

  FutureOr<void> _onSuspend(AdminVendorSuspend e, Emitter<AdminVendorState> emit) =>
      _withReload(() => remote.suspendVendor(e.venderId, e.suspended), emit,
          success: 'Vendor suspension updated.');

  FutureOr<void> _onBlacklist(AdminVendorBlacklist e, Emitter<AdminVendorState> emit) =>
      _withReload(() => remote.blacklistVendor(e.venderId, e.blacklisted), emit,
          success: 'Vendor blacklist updated.');

  FutureOr<void> _onNotify(AdminVendorNotify e, Emitter<AdminVendorState> emit) async {
    try {
      await remote.sendNotification(e.req);
      emit(const AdminVendorActionSuccess('Notification sent.'));
    } catch (ex) {
      emit(AdminVendorFailed(ex.toString()));
    }
  }

  FutureOr<void> _onViolations(
      AdminVendorUpdateViolations e, Emitter<AdminVendorState> emit) =>
      _withReload(() => remote.updateViolations(e.req), emit,
          success: 'Violations updated.');
}
