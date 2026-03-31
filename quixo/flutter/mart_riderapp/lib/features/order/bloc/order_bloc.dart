import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/order_remote.dart';
import 'order_event.dart';
import 'order_state.dart';

class RiderOrderBloc extends Bloc<RiderOrderEvent, RiderOrderState> {
  final RiderOrderRemote remote;

  int _lastPage = 1;
  int _lastLimit = 20;
  String? _lastSearchText;
  String? _lastStatus;
  String? _lastDeliveryCategory;

  RiderOrderBloc(this.remote) : super(RiderOrderInitial()) {
    on<RiderOrderFetchRequested>(_onFetchOrders);
    on<RiderOrderGenerateOtp>(_onGenerateOtp);
    on<RiderOrderDelivered>(_onDelivered);
    on<RiderOrderAcceptRequested>(_onAccept);
    on<RiderOrderRejectRequested>(_onReject);
  }

  FutureOr<void> _onFetchOrders(RiderOrderFetchRequested event, Emitter<RiderOrderState> emit) async {
    _lastPage = event.page;
    _lastLimit = event.limit;
    _lastSearchText = event.searchText;
    _lastStatus = event.status;
    _lastDeliveryCategory = event.deliveryCategory;

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
      add(
        RiderOrderFetchRequested(
          page: _lastPage,
          limit: _lastLimit,
          searchText: _lastSearchText,
          status: _lastStatus,
          deliveryCategory: _lastDeliveryCategory,
        ),
      );
    } catch (e) {
      emit(RiderOrderFailure(e.toString()));
    }
  }

  FutureOr<void> _onAccept(
    RiderOrderAcceptRequested event,
    Emitter<RiderOrderState> emit,
  ) async {
    emit(RiderOrderLoading());
    try {
      final message = await remote.acceptOrder(event.model);
      emit(RiderOrderActionSuccess(message));
      add(
        RiderOrderFetchRequested(
          page: _lastPage,
          limit: _lastLimit,
          searchText: _lastSearchText,
          status: _lastStatus,
          deliveryCategory: _lastDeliveryCategory,
        ),
      );
    } catch (e) {
      emit(RiderOrderActionFailure(e.toString()));
    }
  }

  FutureOr<void> _onReject(
    RiderOrderRejectRequested event,
    Emitter<RiderOrderState> emit,
  ) async {
    emit(RiderOrderLoading());
    try {
      final message = await remote.rejectOrder(event.model);
      emit(RiderOrderActionSuccess(message));
      add(
        RiderOrderFetchRequested(
          page: _lastPage,
          limit: _lastLimit,
          searchText: _lastSearchText,
          status: _lastStatus,
          deliveryCategory: _lastDeliveryCategory,
        ),
      );
    } catch (e) {
      emit(RiderOrderActionFailure(e.toString()));
    }
  }
}