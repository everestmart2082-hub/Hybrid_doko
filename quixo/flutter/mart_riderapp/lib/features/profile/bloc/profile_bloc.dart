import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rider_profile_remote.dart';
import '../data/rider_profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class RiderProfileBloc extends Bloc<RiderProfileEvent, RiderProfileState> {
  final RiderProfileRemote remote;

  RiderProfileBloc(this.remote) : super(RiderProfileInitial()) {
    on<RiderProfileFetchRequested>(_onFetch);
    on<RiderProfileUpdateRequested>(_onUpdate);
    on<RiderProfileDeleteRequested>(_onDelete);
    on<RiderProfileOtpRequested>(_onOtp);
  }

  FutureOr<void> _onFetch(
      RiderProfileFetchRequested event, Emitter<RiderProfileState> emit) async {
    emit(RiderProfileLoading());
    try {
      final res = await remote.getProfile();
      if (res.success) {
        emit(RiderProfileLoaded(RiderProfileModel(
          name: res.name ?? "",
          number: res.number ?? "",
          email: res.email,
          defaultAddress: res.defaultAddress,
          bikeDetail: res.bikeDetail,
        )));
      } else {
        emit(RiderProfileFailure(res.message));
      }
    } catch (e) {
      emit(RiderProfileFailure(e.toString()));
    }
  }

  FutureOr<void> _onUpdate(
      RiderProfileUpdateRequested event, Emitter<RiderProfileState> emit) async {
    emit(RiderProfileLoading());
    try {
      final res = await remote.updateProfile( event.model);
      if (res.success) {
        emit(RiderProfileSuccess(res.message));
      } else {
        emit(RiderProfileFailure(res.message));
      }
    } catch (e) {
      emit(RiderProfileFailure(e.toString()));
    }
  }

  FutureOr<void> _onDelete(
      RiderProfileDeleteRequested event, Emitter<RiderProfileState> emit) async {
    emit(RiderProfileLoading());
    try {
      final res = await remote.deleteProfile( event.reason);
      if (res.success) {
        emit(RiderProfileSuccess(res.message));
      } else {
        emit(RiderProfileFailure(res.message));
      }
    } catch (e) {
      emit(RiderProfileFailure(e.toString()));
    }
  }

  FutureOr<void> _onOtp(
      RiderProfileOtpRequested event, Emitter<RiderProfileState> emit) async {
    emit(RiderProfileLoading());
    try {
      final res = await remote.verifyOtp(event.phone, event.otp);
      if (res.success) {
        emit(RiderProfileSuccess(res.message));
      } else {
        emit(RiderProfileFailure(res.message));
      }
    } catch (e) {
      emit(RiderProfileFailure(e.toString()));
    }
  }
}