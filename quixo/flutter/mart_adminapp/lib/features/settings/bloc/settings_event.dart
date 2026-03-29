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
