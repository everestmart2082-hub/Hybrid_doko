import 'package:equatable/equatable.dart';

abstract class VenderAuthState extends Equatable {
  const VenderAuthState();

  @override
  List<Object?> get props => [];
}

class VenderAuthInitial extends VenderAuthState {}

class VenderAuthLoading extends VenderAuthState {}

/// Shown after login/register API asks for OTP. [session] increments each time so Bloc does not drop
/// the state when it matches a previous [VenderAuthenticated(authenticated: false)] (Equatable).
class VenderAuthOtpStep extends VenderAuthState {
  final bool forRegistration;
  final int session;

  const VenderAuthOtpStep({
    required this.forRegistration,
    required this.session,
  });

  @override
  List<Object?> get props => [forRegistration, session];
}

class VenderAuthenticated extends VenderAuthState {
  final bool authenticated;

  const VenderAuthenticated({required this.authenticated});

  @override
  List<Object?> get props => [authenticated];
}

class VenderUnAuthenticated extends VenderAuthState {}

class VenderAuthFailed extends VenderAuthState {
  final String message;

  const VenderAuthFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class VenderBusinessTypesLoaded extends VenderAuthState {
  final List<dynamic> businessTypes;

  const VenderBusinessTypesLoaded({required this.businessTypes});

  @override
  List<Object?> get props => [businessTypes];
}