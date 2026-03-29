import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/customer/data/admin_customer_model.dart';

abstract class AdminCustomerState extends Equatable {
  const AdminCustomerState();
  @override List<Object?> get props => [];
}

class AdminCustomerInitial extends AdminCustomerState {}
class AdminCustomerLoading extends AdminCustomerState {}

class AdminCustomerLoaded extends AdminCustomerState {
  final List<AdminUserItem> users;
  const AdminCustomerLoaded(this.users);
  @override List<Object?> get props => [users];
}

class AdminCustomerActionSuccess extends AdminCustomerState {
  final String message;
  const AdminCustomerActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class AdminCustomerFailed extends AdminCustomerState {
  final String message;
  const AdminCustomerFailed(this.message);
  @override List<Object?> get props => [message];
}
