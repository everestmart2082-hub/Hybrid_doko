import 'package:equatable/equatable.dart';

abstract class RiderAuthState extends Equatable {
  const RiderAuthState();

  @override
  List<Object?> get props => [];
}

class RiderAuthInitial extends RiderAuthState {}

class RiderAuthLoading extends RiderAuthState {}

class RiderAuthSuccess extends RiderAuthState {
  final String message;
  final String? token;

  const RiderAuthSuccess(this.message, {this.token});

  @override
  List<Object?> get props => [message, token];
}

class RiderUnauthenticated extends RiderAuthState{}

class RiderAuthFailure extends RiderAuthState {
  final String message;

  const RiderAuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}