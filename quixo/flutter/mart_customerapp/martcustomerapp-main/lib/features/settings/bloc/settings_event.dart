abstract class SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String theme;

  ChangeTheme(this.theme);
}
