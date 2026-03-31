import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String theme;

  const SettingsState({required this.theme});

  SettingsState copyWith({String? theme}) {
    return SettingsState(theme: theme ?? "amber-red");
  }

  Map<String, dynamic> toMap() {
    return {"theme": theme};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    final raw = map['theme'];
    final theme = raw is String && raw.isNotEmpty ? raw : 'amber-red';
    return SettingsState(theme: theme);
  }

  @override
  List<Object?> get props => [theme];
}
