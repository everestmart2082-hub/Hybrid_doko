import 'package:equatable/equatable.dart';

abstract class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactSuccess extends ContactState {
  final String message;

  const ContactSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ContactError extends ContactState {
  final String message;

  const ContactError(this.message);

  @override
  List<Object?> get props => [message];
}
