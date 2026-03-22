import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final int page;
  final int limit;
  final String searchText;
  final String status;
  final String deliveryCategory;

  const LoadOrders({
    this.page = 1,
    this.limit = 10,
    this.searchText = "",
    this.status = "",
    this.deliveryCategory = "",
  });

  @override
  List<Object?> get props => [page, limit, searchText, status, deliveryCategory];
}

class PrepareOrder extends OrderEvent {
  final String orderId;

  const PrepareOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}