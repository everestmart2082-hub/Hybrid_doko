import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/order_remote.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRemote repo;

  OrderBloc(this.repo) : super(OrderInitial()) {

    on<LoadOrders>(_onLoadOrders);
    on<PrepareOrder>(_onPrepareOrder);
    // on<AssignRider>(_onAssignRider);

  }

  FutureOr<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await repo.getAllOrders(
        page: event.page,
        limit: event.limit,
        searchText: event.searchText,
        status: event.status,
        deliveryCategory: event.deliveryCategory,
      );
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  FutureOr<void> _onPrepareOrder(PrepareOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await repo.markOrderPrepared(event.orderId);
      emit(const OrderPrepared("Order prepared successfully"));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // FutureOr<void> _onAssignRider(AssignRider event, Emitter<OrderState> emit) async {
  //   emit(OrderLoading());
  //   try {
  //     await repo.assignRider(ordersId: event.ordersId, riderId: event.riderId);
  //     emit(const OrderPrepared("Rider assigned successfully"));
  //   } catch (e) {
  //     emit(OrderError(e.toString()));
  //   }
  // }
}