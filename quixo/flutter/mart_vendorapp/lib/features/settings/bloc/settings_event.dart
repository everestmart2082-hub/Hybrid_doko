abstract class SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String theme;

  ChangeTheme(this.theme);
}

class ChangeLanguage extends SettingsEvent {
  final String language;

  ChangeLanguage(this.language);
}

class LoadSettings extends SettingsEvent {}
