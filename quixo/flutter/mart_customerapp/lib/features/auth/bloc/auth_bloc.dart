
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import 'package:quickmartcustomer/core/network/shared_pref.dart';
import 'package:quickmartcustomer/features/auth/data/auth_token.dart';
import 'package:quickmartcustomer/features/auth/repository/auth_remote.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemote authRemote;
  SharedPreferencesProvider s = SharedPreferencesProvider();

  AuthBloc(this.authRemote) : super(AuthInitial()) {
    on<AuthCheck>(_onAuthCheck);
    on<AuthLogin>(_onLogin);
    on<AuthLoginOtpVerify>(_onLoginOtpVerify);
    on<AuthRegister>(_onRegister);
    on<AuthregisterOtpVerify>(_onRegisterOtpVerify);
    on<AuthLogout>((event, emit)async{
      await s.clearkey(prefs.token.name);
      emit(AuthUnAuthenticated());
    });
  }


  FutureOr<void> _onAuthCheck(AuthCheck event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    bool b = (await s.getKey(prefs.token.name))?.isNotEmpty ?? false;
    if(!b){
      emit(AuthUnAuthenticated());
    } else {
      emit(AuthAuthenticated(authenticated: true));
    }
  }

  FutureOr<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try {
      bool b = await authRemote.login(
        event.input
      );
      if (b) {
        emit(const AuthAuthenticated(authenticated: false)); // false indicates OTP step
      } else {
        emit(const AuthFailed(message: "Login failed"));
      }
    } catch (e) {
      emit(_mapError(e));
    }
  }

  FutureOr<void> _onLoginOtpVerify(AuthLoginOtpVerify event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try {
      AuthToken b = await authRemote.verifyLoginOtp(
        event.input
      );

      s.setKey(prefs.token.name, b.token);

      emit(AuthAuthenticated(authenticated: true));
    } catch (e) {
      emit(_mapError(e));
    }
  }

  FutureOr<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try {
      bool b = await authRemote.register(
        event.input
      );
      if (b) {
        emit(const AuthAuthenticated(authenticated: false));
      } else {
        emit(const AuthFailed(message: "Registration failed"));
      }
    } catch (e) {
      emit(_mapError(e));
    }
  }

  FutureOr<void> _onRegisterOtpVerify(AuthregisterOtpVerify event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try {
      AuthToken b = await authRemote.verifyRegisterOtp(
        event.input
      );

      s.setKey(prefs.token.name, b.token);

      emit(AuthAuthenticated(authenticated: true));
    } catch (e) {
      emit(_mapError(e));
    }
  }

  AuthFailed _mapError(Object e) {
    if (e is Failure) {
      return AuthFailed(message: e.message);
    }
    return const AuthFailed(message: 'Something went wrong');
  }

}