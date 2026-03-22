import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/core/network/shared_pref.dart';

import '../repository/auth_remote.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class RiderAuthBloc extends Bloc<RiderAuthEvent, RiderAuthState> {
  final RiderAuthRemote remote;
  SharedPreferencesProvider s  = SharedPreferencesProvider();

  RiderAuthBloc(this.remote) : super(RiderAuthInitial()) {
    on<RiderRegisterRequested>(_onRegister);
    on<RiderRegistrationOtpRequested>(_onRegisterOtp);
    on<RiderLoginRequested>(_onLogin);
    on<RiderLoginOtpRequested>(_onLoginOtp);
    on<AuthCheck>(_onAuthCheck);
    on<RiderAuthLogout>((event, emit)async{
      await s.clearkey(prefs.token.name);
      emit(RiderUnauthenticated());
    });
  }

  FutureOr<void> _onAuthCheck(AuthCheck event, Emitter<RiderAuthState> emit) async{
    emit(RiderAuthLoading());
    bool b = (await s.getKey(prefs.token.name))!.isNotEmpty;
    if(!b){
      emit(RiderAuthFailure("Token not found"));
    }

    emit(RiderAuthSuccess(b.toString(),token: s.getKey(prefs.token.name) as String?));
  }

  FutureOr<void> _handleAuth(
      Future future,
      Emitter<RiderAuthState> emit) async {
    emit(RiderAuthLoading());
    try {
      final response = await future;
      if (response.success) {
        s.setKey(prefs.token.name,response.token);
        emit(RiderAuthSuccess(response.message,
            token: response.token));
      } else {
        emit(RiderAuthFailure(response.message));
      }
    } catch (e) {
      emit(RiderAuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onRegister(
      RiderRegisterRequested event,
      Emitter<RiderAuthState> emit) async {
    await _handleAuth(remote.register(event.model), emit);
  }

  FutureOr<void> _onRegisterOtp(
      RiderRegistrationOtpRequested event,
      Emitter<RiderAuthState> emit) async {
    await _handleAuth(remote.verifyRegistrationOtp(event.model), emit);
  }

  FutureOr<void> _onLogin(
      RiderLoginRequested event,
      Emitter<RiderAuthState> emit) async {
    await _handleAuth(remote.login(event.model), emit);
  }

  FutureOr<void> _onLoginOtp(
      RiderLoginOtpRequested event,
      Emitter<RiderAuthState> emit) async {
    await _handleAuth(remote.verifyLoginOtp(event.model), emit);
  }
}
