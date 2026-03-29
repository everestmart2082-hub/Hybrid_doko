import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/orders/repository/admin_orders_remote.dart';
import 'admin_order_event.dart';
import 'admin_order_state.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final AdminOrdersRemote remote;

  AdminOrderBloc(this.remote) : super(AdminOrderInitial()) {
    on<AdminOrderLoad>(_onLoad);
  }

  FutureOr<void> _onLoad(AdminOrderLoad _, Emitter<AdminOrderState> emit) async {
    emit(AdminOrderLoading());
    try {
      emit(AdminOrderLoaded(await remote.getAllOrders()));
    } catch (e) {
      emit(AdminOrderFailed(e.toString()));
    }
  }
}
