import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String theme;
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const SettingsState({
    required this.theme,
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? theme,
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {"theme": theme};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(theme: map['theme'] ?? "amber-red");
  }

  @override
  List<Object?> get props => [theme, isLoading, successMessage, errorMessage];
}
