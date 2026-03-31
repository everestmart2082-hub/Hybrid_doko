import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/contact_remote.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRemote contactRemote;

  ContactBloc(this.contactRemote) : super(ContactInitial()) {
    on<SendContactMessage>(_onSendContactMessage);
  }

  FutureOr<void> _onSendContactMessage(
    SendContactMessage event,
    Emitter<ContactState> emit,
  ) async {
    emit(ContactLoading());
    try {
      // Simple client-side validation to provide quick feedback.
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

      final response = await contactRemote.sendMessage(
        name: event.name,
        email: event.email,
        message: event.message,
      );

      if (response.success) {
        emit(ContactSuccess(response.message));
      } else {
        emit(ContactError(response.message));
      }
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}

