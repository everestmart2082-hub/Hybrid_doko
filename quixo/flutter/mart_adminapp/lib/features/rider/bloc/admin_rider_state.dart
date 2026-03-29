import 'package:equatable/equatable.dart';
import 'package:mart_adminapp/features/rider/data/admin_rider_model.dart';

abstract class AdminRiderState extends Equatable {
  const AdminRiderState();
  @override List<Object?> get props => [];
}

class AdminRiderInitial extends AdminRiderState {}
class AdminRiderLoading extends AdminRiderState {}

class AdminRiderLoaded extends AdminRiderState {
  final List<AdminRiderItem> riders;
  const AdminRiderLoaded(this.riders);
  @override List<Object?> get props => [riders];
}

class AdminRiderActionSuccess extends AdminRiderState {
  final String message;
  const AdminRiderActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class AdminRiderFailed extends AdminRiderState {
  final String message;
  const AdminRiderFailed(this.message);
  @override List<Object?> get props => [message];
}
