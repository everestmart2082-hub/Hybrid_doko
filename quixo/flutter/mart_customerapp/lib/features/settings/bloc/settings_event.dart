import '../data/settings_request_models.dart';

abstract class SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String theme;

  ChangeTheme(this.theme);
}

class SettingsSendMessageRequested extends SettingsEvent {
  final SendMessageRequestModel request;

  SettingsSendMessageRequested(this.request);
}
