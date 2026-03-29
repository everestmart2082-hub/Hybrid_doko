import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/profile/repository/admin_profile_remote.dart';
import 'admin_profile_event.dart';
import 'admin_profile_state.dart';

class AdminProfileBloc extends Bloc<AdminProfileEvent, AdminProfileState> {
  final AdminProfileRemote remote;

  AdminProfileBloc(this.remote) : super(AdminProfileInitial()) {
    on<AdminProfileLoad>(_onLoad);
    on<AdminProfileUpdate>(_onUpdate);
    on<AdminProfileOtpVerify>(_onOtpVerify);
    on<AdminProfileDelete>(_onDelete);
    on<AdminAddNewAdmin>(_onAddNewAdmin);
    on<AdminAddNewAdminOtpVerify>(_onAddNewAdminOtpVerify);
  }

  FutureOr<void> _onLoad(
      AdminProfileLoad event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      final profile = await remote.getProfile();
      emit(AdminProfileLoaded(profile));
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }

  FutureOr<void> _onUpdate(
      AdminProfileUpdate event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      await remote.updateProfile(event.req);
      emit(AdminProfileUpdatePending());
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }

  FutureOr<void> _onOtpVerify(
      AdminProfileOtpVerify event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      await remote.verifyUpdateOtp(event.otp);
      emit(const AdminProfileSuccess('Profile updated successfully.'));
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }

  FutureOr<void> _onDelete(
      AdminProfileDelete event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      await remote.deleteProfile(event.req);
      emit(const AdminProfileSuccess('Account action completed.'));
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }

  FutureOr<void> _onAddNewAdmin(
      AdminAddNewAdmin event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      // Re-uses auth remote's addAdmin; OTP next step handled by AdminAuthBloc.
      // Here we just trigger the profile-add flow.
      emit(AdminProfileUpdatePending());
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }

  FutureOr<void> _onAddNewAdminOtpVerify(
      AdminAddNewAdminOtpVerify event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      await remote.verifyAddOtp(event.phone, event.otp);
      emit(const AdminProfileSuccess('New admin added successfully.'));
    } catch (e) {
      emit(AdminProfileFailed(e.toString()));
    }
  }
}
