import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/orders/data/admin_order_model.dart';

abstract class AdminOrderState extends Equatable {
  const AdminOrderState();
  @override List<Object?> get props => [];
}

class AdminOrderInitial extends AdminOrderState {}
class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final List<AdminOrderItem> orders;
  const AdminOrderLoaded(this.orders);
  @override List<Object?> get props => [orders];
}

class AdminOrderFailed extends AdminOrderState {
  final String message;
  const AdminOrderFailed(this.message);
  @override List<Object?> get props => [message];
}
