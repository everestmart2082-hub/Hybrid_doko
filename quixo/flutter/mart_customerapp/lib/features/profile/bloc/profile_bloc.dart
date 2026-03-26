import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/failures/failures.dart';
import '../repository/profile_remote.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRemote remote;

  ProfileBloc(this.remote) : super(ProfileInitial()) {
    on<ProfileGet>(_onGet);
    on<ProfileUpdate>(_onUpdate);
    on<ProfileDelete>(_onDelete);
    on<ProfileVerifyOtp>(_onVerifyOtp);
  }

  Future<void> _onGet(
      ProfileGet event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      final profile = await remote.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> _onUpdate(
      ProfileUpdate event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      await remote.updateProfile(event.profile);
      emit(ProfileSuccess());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> _onDelete(
      ProfileDelete event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      await remote.deleteProfile(event.model);
      emit(ProfileSuccess());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  Future<void> _onVerifyOtp(
      ProfileVerifyOtp event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      await remote.verifyProfileOtp(event.model);
      emit(ProfileSuccess());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  ProfileFailed _mapError(Object e) {
    if (e is Failure) {
      return ProfileFailed(e.message);
    }
    return const ProfileFailed("Something went wrong");
  }
}