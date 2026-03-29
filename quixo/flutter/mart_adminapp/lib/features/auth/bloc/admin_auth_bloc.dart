import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/auth/data/admin_auth_model.dart';
import 'package:mart_adminapp/features/auth/repository/admin_auth_remote.dart';
import 'admin_auth_event.dart';
import 'admin_auth_state.dart';

class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final AdminAuthRemote remote;

  AdminAuthBloc(this.remote) : super(AdminAuthInitial()) {
    on<AdminAuthCheck>(_onCheck);
    on<AdminLogin>(_onLogin);
    on<AdminLoginOtpVerify>(_onLoginOtpVerify);
    on<AdminLogout>(_onLogout);
    on<AdminAddAdmin>(_onAddAdmin);
    on<AdminAddAdminOtpVerify>(_onAddAdminOtpVerify);

    add(AdminAuthCheck());
  }

  FutureOr<void> _onCheck(
      AdminAuthCheck event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      final token = await remote.getStoredToken();
      if (token != null && token.isNotEmpty) {
        emit(const AdminAuthenticated(authenticated: true));
      } else {
        emit(AdminUnauthenticated());
      }
    } catch (_) {
      emit(AdminUnauthenticated());
    }
  }

  FutureOr<void> _onLogin(
      AdminLogin event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      await remote.login(event.phone);
      emit(AdminAuthOtpSent(phone: event.phone));
    } catch (e) {
      emit(AdminAuthFailed(message: e.toString()));
    }
  }

  FutureOr<void> _onLoginOtpVerify(
      AdminLoginOtpVerify event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      final token = await remote.verifyLoginOtp(
          AdminOtpLoginRequest(phone: event.phone, otp: event.otp));
      await remote.persistToken(token.token);
      emit(const AdminAuthenticated(authenticated: true));
    } catch (e) {
      emit(AdminAuthFailed(message: e.toString()));
    }
  }

  FutureOr<void> _onLogout(
      AdminLogout event, Emitter<AdminAuthState> emit) async {
    await remote.clearToken();
    emit(AdminUnauthenticated());
  }

  FutureOr<void> _onAddAdmin(
      AdminAddAdmin event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      await remote.addAdmin(AdminAddRequest(
          name: event.name, email: event.email, number: event.number));
      emit(AdminAddAdminOtpSent(number: event.number));
    } catch (e) {
      emit(AdminAuthFailed(message: e.toString()));
    }
  }

  FutureOr<void> _onAddAdminOtpVerify(
      AdminAddAdminOtpVerify event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      await remote.verifyAddAdminOtp(
          AdminAddOtpRequest(number: event.number, otp: event.otp));
      emit(AdminAuthSuccess());
    } catch (e) {
      emit(AdminAuthFailed(message: e.toString()));
    }
  }
}
