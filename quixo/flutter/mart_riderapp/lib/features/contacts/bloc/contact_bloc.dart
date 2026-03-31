import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/contacts_remote.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class RiderContactsBloc extends Bloc<RiderContactEvent, RiderContactState> {
  final RiderContactsRemote remote;

  RiderContactsBloc(this.remote) : super(const RiderContactInitial()) {
    on<SendRiderContactMessage>(_onSend);
  }

  FutureOr<void> _onSend(
    SendRiderContactMessage event,
    Emitter<RiderContactState> emit,
  ) async {
    emit(const RiderContactLoading());
    try {
      final name = event.name.trim();
      final email = event.email.trim();
      final message = event.message.trim();

      if (name.isEmpty || email.isEmpty || message.isEmpty) {
        emit(const RiderContactFailure("All fields are required."));
        return;
      }

      final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
      if (!emailRegex.hasMatch(email)) {
        emit(const RiderContactFailure("Please enter a valid email address."));
        return;
      }

      final res = await remote.sendMessage(
        name: name,
        email: email,
        message: message,
      );

      if (res.success) {
        emit(RiderContactSuccess(res.message));
      } else {
        emit(RiderContactFailure(res.message));
      }
    } catch (e) {
      emit(RiderContactFailure(e.toString()));
    }
  }
}

