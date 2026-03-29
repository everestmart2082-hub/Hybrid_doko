import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/network/shared_pref.dart';

import '../repository/settings_remote.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesProvider s = SharedPreferencesProvider();
  final SettingsRemote settingsRemote;

  SettingsBloc(this.settingsRemote) : super(const SettingsState(theme: 'amber-red')) {
    // 1️⃣ Load saved theme asynchronously
    _loadSavedTheme();

    // 2️⃣ Listen for ChangeTheme events
    on<ChangeTheme>((event, emit) {
      s.setKey(prefs.theme.name, event.theme); // save
      emit(state.copyWith(theme: event.theme)); // update state
    });

    on<SettingsSendMessageRequested>((event, emit) async {
      emit(state.copyWith(isLoading: true, successMessage: null, errorMessage: null));
      try {
        final response = await settingsRemote.sendMessage(event.request);
        emit(state.copyWith(isLoading: false, successMessage: response.message));
      } catch (e) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    });
  }

  void _loadSavedTheme() async {
    final savedTheme = await s.getKey(prefs.theme.name);
    if (savedTheme != null && savedTheme.isNotEmpty) {
      add(ChangeTheme(savedTheme)); 
    }
  }
}