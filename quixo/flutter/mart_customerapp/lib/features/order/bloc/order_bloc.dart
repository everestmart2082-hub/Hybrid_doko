import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/order_query_model.dart';
import '../repository/order_remote.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRemote orderRemote;

  OrderBloc(this.orderRemote) : super(OrderInitial()) {
    on<OrderFetchRequested>(_onFetch);
    on<OrderCancelRequested>(_onCancel);
    on<OrderCancelAllRequested>(_onCancelAll);
    on<OrderReorderRequested>(_onReorder);
    on<OrderRiderRatingRequested>(_onRiderRating);
  }

  FutureOr<void> _onFetch(
      OrderFetchRequested event,
      Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders =
          await orderRemote.getAllOrders(event.query);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderFailed(e.toString()));
    }
  }

  FutureOr<void> _onCancel(
      OrderCancelRequested event,
      Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final response =
          await orderRemote.cancelOrder(event.orderId);

      emit(OrderActionSuccess(response.message));

      add(OrderFetchRequested(const OrderQueryModel()));
    } catch (e) {
      emit(OrderFailed(e.toString()));
    }
  }

  FutureOr<void> _onCancelAll(
    OrderCancelAllRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      int cancelledCount = 0;
      int skippedCount = 0;
      String lastSkipMessage = '';

      for (final orderId in event.orderIds) {
        final response = await orderRemote.cancelOrder(orderId);
        if (response.success) {
          cancelledCount++;
        } else {
          skippedCount++;
          lastSkipMessage = response.message;
        }
      }

      final message = skippedCount == 0
          ? 'All orders cancelled successfully'
          : 'Cancelled $cancelledCount orders, skipped $skippedCount ($lastSkipMessage)';

      emit(OrderActionSuccess(message));

      // Refresh orders after cancel-all attempt.
      add(OrderFetchRequested(const OrderQueryModel()));
    } catch (e) {
      emit(OrderFailed(e.toString()));
    }
  }

  FutureOr<void> _onReorder(
      OrderReorderRequested event,
      Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final response =
          await orderRemote.reorder(event.orderId);

      emit(OrderActionSuccess(response.message));
    } catch (e) {
      emit(OrderFailed(e.toString()));
    }
  }

  FutureOr<void> _onRiderRating(
      OrderRiderRatingRequested event,
      Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final response =
          await orderRemote.rateRider(event.request);

      emit(OrderActionSuccess(response.message));

      // Refresh orders after rating
      add(OrderFetchRequested(const OrderQueryModel()));
    } catch (e) {
      emit(OrderFailed(e.toString()));
    }
  }
}