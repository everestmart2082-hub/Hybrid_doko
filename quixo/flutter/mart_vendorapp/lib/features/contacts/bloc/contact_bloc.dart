import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'contact_event.dart';
import 'contact_state.dart';

/// A simple local-only BLoC for the Contact Us form.
/// The Contacts page (from contacts.txt) takes Name, Email, and Message.
/// Since there is no backend endpoint for this, we simulate sending and
/// emit success/failure immediately. When a real API is available, inject
/// a repository here and call it.
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<SendContactMessage>(_onSendContactMessage);
  }

  FutureOr<void> _onSendContactMessage(
      SendContactMessage event, Emitter<ContactState> emit) async {
    emit(ContactLoading());

    try {
      // Basic validation
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

      // TODO: call a real API endpoint when one is available
      // e.g. await dio.post("/api/contact", {...})

      emit(const ContactSuccess("Your message has been sent. We will get back to you soon."));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}
