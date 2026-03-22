import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/order_remote.dart';
import 'order_event.dart';
import 'order_state.dart';

class RiderOrderBloc extends Bloc<RiderOrderEvent, RiderOrderState> {
  final RiderOrderRemote remote;

  RiderOrderBloc(this.remote) : super(RiderOrderInitial()) {
    on<RiderOrderFetchRequested>(_onFetchOrders);
    on<RiderOrderGenerateOtp>(_onGenerateOtp);
    on<RiderOrderDelivered>(_onDelivered);
  }

  FutureOr<void> _onFetchOrders(RiderOrderFetchRequested event, Emitter<RiderOrderState> emit) async {
    emit(RiderOrderLoading());
    try {
      final orders = await remote.fetchOrders(
        page: event.page,
        limit: event.limit,
        searchText: event.searchText,
        status: event.status,
        deliveryCategory: event.deliveryCategory,
      );
      emit(RiderOrderLoaded(orders));
    } catch (e) {
      emit(RiderOrderFailure(e.toString()));
    }
  }

  FutureOr<void> _onGenerateOtp(RiderOrderGenerateOtp event, Emitter<RiderOrderState> emit) async {
    emit(RiderOrderLoading());
    try {
      final message = await remote.generateOtp(event.model);
      emit(RiderOrderOtpGenerated(message));
    } catch (e) {
      emit(RiderOrderFailure(e.toString()));
    }
  }

  FutureOr<void> _onDelivered(RiderOrderDelivered event, Emitter<RiderOrderState> emit) async {
    emit(RiderOrderLoading());
    try {
      final message = await remote.markDelivered(event.model);
      emit(RiderOrderDeliveredSuccess(message));
    } catch (e) {
      emit(RiderOrderFailure(e.toString()));
    }
  }
}