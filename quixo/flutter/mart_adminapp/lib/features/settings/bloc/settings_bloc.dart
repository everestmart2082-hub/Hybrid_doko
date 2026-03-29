import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/core/network/shared_pref.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesProvider s = SharedPreferencesProvider();

  SettingsBloc()
      : super(const SettingsState(theme: 'amberDark', language: 'English')) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLanguage>(_onChangeLanguage);
    add(LoadSettings());
  }

  FutureOr<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final savedTheme = await s.getKey(prefs.theme.name);
    final savedLanguage = await s.getKey(prefs.language.name);
    emit(state.copyWith(
      theme: (savedTheme != null && savedTheme.isNotEmpty)
          ? savedTheme
          : 'amberDark',
      language: (savedLanguage != null && savedLanguage.isNotEmpty)
          ? savedLanguage
          : 'English',
    ));
  }

  FutureOr<void> _onChangeTheme(
      ChangeTheme event, Emitter<SettingsState> emit) async {
    await s.setKey(prefs.theme.name, event.theme);
    emit(state.copyWith(theme: event.theme));
  }

  FutureOr<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<SettingsState> emit) async {
    await s.setKey(prefs.language.name, event.language);
    emit(state.copyWith(language: event.language));
  }
}
