import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/rider/repository/admin_rider_remote.dart';
import 'admin_rider_event.dart';
import 'admin_rider_state.dart';

class AdminRiderBloc extends Bloc<AdminRiderEvent, AdminRiderState> {
  final AdminRiderRemote remote;

  AdminRiderBloc(this.remote) : super(AdminRiderInitial()) {
    on<AdminRiderLoad>(_onLoad);
    on<AdminRiderApprove>(_onApprove);
    on<AdminRiderSuspend>(_onSuspend);
    on<AdminRiderBlacklist>(_onBlacklist);
    on<AdminRiderNotify>(_onNotify);
    on<AdminRiderUpdateViolations>(_onViolations);
  }

  FutureOr<void> _onLoad(AdminRiderLoad _, Emitter<AdminRiderState> emit) async {
    emit(AdminRiderLoading());
    try {
      emit(AdminRiderLoaded(await remote.getAllRiders()));
    } catch (e) {
      emit(AdminRiderFailed(e.toString()));
    }
  }

  FutureOr<void> _withReload(Future<void> Function() action,
      Emitter<AdminRiderState> emit, {String success = 'Done'}) async {
    emit(AdminRiderLoading());
    try {
      await action();
      emit(AdminRiderActionSuccess(success));
      emit(AdminRiderLoaded(await remote.getAllRiders()));
    } catch (e) {
      emit(AdminRiderFailed(e.toString()));
    }
  }

  FutureOr<void> _onApprove(AdminRiderApprove e, Emitter<AdminRiderState> emit) =>
      _withReload(() => remote.approveRider(e.riderId, e.approved), emit,
          success: 'Rider approval updated.');

  FutureOr<void> _onSuspend(AdminRiderSuspend e, Emitter<AdminRiderState> emit) =>
      _withReload(() => remote.suspendRider(e.riderId, e.suspended), emit,
          success: 'Rider suspension updated.');

  FutureOr<void> _onBlacklist(AdminRiderBlacklist e, Emitter<AdminRiderState> emit) =>
      _withReload(() => remote.blacklistRider(e.riderId, e.blacklisted), emit,
          success: 'Rider blacklist updated.');

  FutureOr<void> _onNotify(AdminRiderNotify e, Emitter<AdminRiderState> emit) =>
      _withReload(() => remote.sendNotification(e.riderId, e.message), emit,
          success: 'Notification sent.');

  FutureOr<void> _onViolations(
      AdminRiderUpdateViolations e, Emitter<AdminRiderState> emit) =>
      _withReload(() => remote.updateViolations(e.riderId, e.violations), emit,
          success: 'Violations updated.');
}
