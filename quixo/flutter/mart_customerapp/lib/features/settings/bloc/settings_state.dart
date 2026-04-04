import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String theme;
  final String language;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const SettingsState({
    required this.theme,
    this.language = 'English',
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? theme,
    String? language,
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [theme, language, isLoading, successMessage, errorMessage];
}
