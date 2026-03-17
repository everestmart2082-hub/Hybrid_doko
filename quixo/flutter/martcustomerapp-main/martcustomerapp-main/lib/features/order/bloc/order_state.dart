import 'package:equatable/equatable.dart';
import '../data/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;

  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderActionSuccess extends OrderState {
  final String message;

  const OrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderFailed extends OrderState {
  final String message;

  const OrderFailed(this.message);

  @override
  List<Object?> get props => [message];
}
