import 'package:equatable/equatable.dart';

abstract class RiderContactState extends Equatable {
  const RiderContactState();

  @override
  List<Object?> get props => [];
}

class RiderContactInitial extends RiderContactState {
  const RiderContactInitial();
}

class RiderContactLoading extends RiderContactState {
  const RiderContactLoading();
}

class RiderContactSuccess extends RiderContactState {
  final String message;

  const RiderContactSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RiderContactFailure extends RiderContactState {
  final String message;

  const RiderContactFailure(this.message);

  @override
  List<Object?> get props => [message];
}

