import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String theme;
  final String language;

  const SettingsState({required this.theme, this.language = 'English'});

  SettingsState copyWith({String? theme, String? language}) => SettingsState(
        theme: theme ?? this.theme,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => [theme, language];
}
