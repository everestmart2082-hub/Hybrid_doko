import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String theme;
  final String language;

  const SettingsState({
    required this.theme,
    this.language = 'English',
  });

  SettingsState copyWith({String? theme, String? language}) {
    return SettingsState(
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {"theme": theme, "language": language};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      theme: map['theme'] ?? 'amberDark',
      language: map['language'] ?? 'English',
    );
  }

  @override
  List<Object?> get props => [theme, language];
}
