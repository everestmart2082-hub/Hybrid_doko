
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState{}

class AuthLoading extends AuthState{}

class AuthAuthenticated extends AuthState{
  final bool authenticated;

  const AuthAuthenticated({required this.authenticated});

  @override
  List<Object?> get props => [authenticated];
}

class AuthUnAuthenticated extends AuthState{}

class AuthFailed extends AuthState{
  final String message;

  const AuthFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
