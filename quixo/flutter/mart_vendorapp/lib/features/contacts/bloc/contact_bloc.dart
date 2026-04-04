import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/contacts/repository/contact_remote.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemote _remote;

  ContactBloc(this._remote) : super(ContactInitial()) {
    on<SendContactMessage>(_onSendContactMessage);
  }

  FutureOr<void> _onSendContactMessage(
      SendContactMessage event, Emitter<ContactState> emit) async {
    emit(ContactLoading());

    try {
      if (event.name.trim().isEmpty ||
          event.email.trim().isEmpty ||
          event.message.trim().isEmpty) {
        emit(const ContactError("All fields are required."));
        return;
      }

      final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
      if (!emailRegex.hasMatch(event.email.trim())) {
        emit(const ContactError("Please enter a valid email address."));
        return;
      }

      await _remote.sendToAdmin(
        name: event.name.trim(),
        email: event.email.trim(),
        message: event.message.trim(),
      );

      emit(const ContactSuccess(
          "Your message has been sent. We will get back to you soon."));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}
