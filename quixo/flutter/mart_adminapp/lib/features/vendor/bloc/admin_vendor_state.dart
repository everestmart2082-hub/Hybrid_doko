import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/vendor/data/admin_vendor_model.dart';

abstract class AdminVendorState extends Equatable {
  const AdminVendorState();
  @override List<Object?> get props => [];
}

class AdminVendorInitial extends AdminVendorState {}
class AdminVendorLoading extends AdminVendorState {}

class AdminVendorLoaded extends AdminVendorState {
  final List<AdminVendorItem> vendors;
  const AdminVendorLoaded(this.vendors);
  @override List<Object?> get props => [vendors];
}

class AdminVendorActionSuccess extends AdminVendorState {
  final String message;
  const AdminVendorActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class AdminVendorFailed extends AdminVendorState {
  final String message;
  const AdminVendorFailed(this.message);
  @override List<Object?> get props => [message];
}
