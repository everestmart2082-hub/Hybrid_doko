import '../data/settings_request_models.dart';

abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String theme;
  ChangeTheme(this.theme);
}

class ChangeLanguage extends SettingsEvent {
  final String language;
  ChangeLanguage(this.language);
}

class SettingsSendMessageRequested extends SettingsEvent {
  final SendMessageRequestModel request;
  SettingsSendMessageRequested(this.request);
}
