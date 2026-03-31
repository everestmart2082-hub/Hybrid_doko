import 'package:equatable/equatable.dart';

abstract class RiderContactEvent extends Equatable {
  const RiderContactEvent();

  @override
  List<Object?> get props => [];
}

class SendRiderContactMessage extends RiderContactEvent {
  final String name;
  final String email;
  final String message;

  const SendRiderContactMessage({
    required this.name,
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [name, email, message];
}

