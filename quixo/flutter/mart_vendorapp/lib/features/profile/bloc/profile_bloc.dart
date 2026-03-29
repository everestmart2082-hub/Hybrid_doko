import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/failures/failures.dart';

import '../repository/profile_remote.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final ProfileRemote remote;

  ProfileBloc(this.remote) : super(ProfileInitial()) {

    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<VerifyProfileOtp>(_onVerifyOtp);
    on<DeleteProfile>(_onDeleteProfile);
  }

  FutureOr<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit) async {

    emit(ProfileLoading());

    try {

      final profile = await remote.getProfile();

      emit(ProfileLoaded(profile: profile));

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onUpdateProfile(
      UpdateProfile event,
      Emitter<ProfileState> emit) async {

    emit(ProfileLoading());

    try {

      bool success = await remote.updateProfile(event.profile);

      if (success) {
        // OTP has been sent to user's number — trigger OTP dialog in UI
        emit(ProfileOtpRequired());
      }

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onVerifyOtp(
      VerifyProfileOtp event,
      Emitter<ProfileState> emit) async {

    emit(ProfileLoading());

    try {

      bool success = await remote.verifyOtp(
        event.phone,
        event.otp,
      );

      if (success) {
        // Successfully updated — show success dialog, disable edit, show green tick
        emit(const ProfileUpdateSuccess("Profile update request submitted successfully"));
      }

    } catch (e) {

      emit(_mapError(e));

    }
  }

  FutureOr<void> _onDeleteProfile(
      DeleteProfile event,
      Emitter<ProfileState> emit) async {

    emit(ProfileLoading());

    try {

      bool success = await remote.deleteProfile(event.model);

      if (success) {
        emit(ProfileDeleted());
      }

    } catch (e) {

      emit(_mapError(e));

    }
  }

  ProfileFailed _mapError(Object e) {

    if (e is Failure) {
      return ProfileFailed(message: e.message);
    }

    return const ProfileFailed(message: "Something went wrong");
  }

}