import 'package:equatable/equatable.dart';
import '../data/address_request_model.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class AddressFetchRequested extends AddressEvent {
  final int page;
  final int limit;

  const AddressFetchRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class AddressAddRequested extends AddressEvent {
  final AddressRequestModel address;

  const AddressAddRequested(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressUpdateRequested extends AddressEvent {
  final AddressRequestModel address;

  const AddressUpdateRequested(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressDeleteRequested extends AddressEvent {
  final String addressId;

  const AddressDeleteRequested(this.addressId);

  @override
  List<Object?> get props => [addressId];
}