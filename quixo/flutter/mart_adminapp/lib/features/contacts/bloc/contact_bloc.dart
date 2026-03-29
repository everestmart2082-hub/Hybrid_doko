import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'contact_event.dart';
import 'contact_state.dart';

/// Local-only BLoC for the Contact Us form (no backend endpoint).
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<SendContactMessage>(_onSend);
  }

  FutureOr<void> _onSend(
      SendContactMessage event, Emitter<ContactState> emit) async {
    emit(ContactLoading());
    try {
      if (event.name.trim().isEmpty ||
          event.email.trim().isEmpty ||
          event.message.trim().isEmpty) {
        emit(const ContactError('All fields are required.'));
        return;
      }
      final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
      if (!emailRegex.hasMatch(event.email.trim())) {
        emit(const ContactError('Please enter a valid email address.'));
        return;
      }
      emit(const ContactSuccess(
          'Your message has been sent. We will get back to you soon.'));
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }
}
