import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/shared_pref.dart';

import '../data/auth_token_model.dart';
import '../repository/auth_remote.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class VenderAuthBloc extends Bloc<VenderAuthEvent, VenderAuthState> {

  final VenderAuthRemote authRemote;
  SharedPreferencesProvider s = SharedPreferencesProvider();

  VenderAuthBloc(this.authRemote) : super(VenderAuthInitial()) {

    on<VenderAuthCheck>(_onAuthCheck);
    on<VenderRegister>(_onRegister);
    on<VenderRegisterOtpVerify>(_onRegisterOtpVerify);
    on<VenderLogin>(_onLogin);
    on<VenderLoginOtpVerify>(_onLoginOtpVerify);
    on<VenderFetchBusinessTypes>(_onFetchBusinessTypes);

    on<VenderLogout>((event, emit) async {
      await s.clearkey(prefs.token.name);
      emit(VenderUnAuthenticated());
    });
  }

  FutureOr<void> _onAuthCheck(
      VenderAuthCheck event,
      Emitter<VenderAuthState> emit) async {

    emit(VenderAuthLoading());

    bool b = (await s.getKey(prefs.token.name))!.isNotEmpty;

    if (!b) {
      emit(const VenderAuthFailed(message: "Token not found"));
    }

    emit(VenderAuthenticated(authenticated: b));
  }

  FutureOr<void> _onRegister(
      VenderRegister event,
      Emitter<VenderAuthState> emit) async {

    emit(VenderAuthLoading());

    try {

      bool b = await authRemote.register(event.input, event.files);

      emit(VenderAuthenticated(authenticated: false));

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onRegisterOtpVerify(
      VenderRegisterOtpVerify event,
      Emitter<VenderAuthState> emit) async {

    emit(VenderAuthLoading());

    try {

      VenderAuthToken token =
          await authRemote.verifyRegisterOtp(event.input);

      await s.setKey(prefs.token.name, token.token);

      emit(const VenderAuthenticated(authenticated: true));

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onLogin(
      VenderLogin event,
      Emitter<VenderAuthState> emit) async {

    emit(VenderAuthLoading());

    try {

      bool b = await authRemote.login(event.phone);

      emit(VenderAuthenticated(authenticated: false));

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onLoginOtpVerify(
      VenderLoginOtpVerify event,
      Emitter<VenderAuthState> emit) async {

    emit(VenderAuthLoading());

    try {

      VenderAuthToken token =
          await authRemote.verifyLoginOtp(event.input);

      await s.setKey(prefs.token.name, token.token);

      emit(const VenderAuthenticated(authenticated: true));

    } catch (e) {

      emit(_mapError(e));

    }
  }

  VenderAuthFailed _mapError(Object e) {

    if (e is Failure) {
      return VenderAuthFailed(message: e.message);
    }

    return const VenderAuthFailed(message: "Something went wrong");
  }

  FutureOr<void> _onFetchBusinessTypes(
      VenderFetchBusinessTypes event,
      Emitter<VenderAuthState> emit) async {
    emit(VenderAuthLoading());
    try {
      final businessTypes = await authRemote.fetchBusinessTypes();
      emit(VenderBusinessTypesLoaded(businessTypes: businessTypes));
    } catch (e) {
      emit(_mapError(e));
    }
  }
}