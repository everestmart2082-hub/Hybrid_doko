import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/payment_remote.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRemote paymentRemote;

  PaymentBloc(this.paymentRemote) : super(PaymentInitial()) {
    on<CheckoutRequested>(_onCheckout);
    on<PaymentStatusRequested>(_onPaymentStatus);
  }

  FutureOr<void> _onCheckout(
      CheckoutRequested event,
      Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final response =
          await paymentRemote.checkout(event.request);

      emit(PaymentSuccess(response.message));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  FutureOr<void> _onPaymentStatus(
      PaymentStatusRequested event,
      Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final response =
          await paymentRemote.checkPaymentStatus(event.query);

      emit(PaymentSuccess(response.message));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }
}