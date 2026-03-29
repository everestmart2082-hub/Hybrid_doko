import 'package:equatable/equatable.dart';

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();
  @override List<Object?> get props => [];
}

class AdminOrderLoad extends AdminOrderEvent {}
