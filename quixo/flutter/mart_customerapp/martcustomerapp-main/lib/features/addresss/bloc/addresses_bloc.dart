import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/address_remote.dart';
import 'addresses_event.dart';
import 'addresses_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRemote addressRemote;

  AddressBloc(this.addressRemote) : super(AddressInitial()) {
    on<AddressFetchRequested>(_onFetch);
    on<AddressAddRequested>(_onAdd);
    on<AddressUpdateRequested>(_onUpdate);
    on<AddressDeleteRequested>(_onDelete);
  }

  FutureOr<void> _onFetch(
      AddressFetchRequested event,
      Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await addressRemote.getAllAddresses(
        page: event.page,
        limit: event.limit,
      );
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressFailed(e.toString()));
    }
  }

  FutureOr<void> _onAdd(
      AddressAddRequested event,
      Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final response = await addressRemote.addAddress(event.address);
      emit(AddressActionSuccess(response.message));
    } catch (e) {
      emit(AddressFailed(e.toString()));
    }
  }

  FutureOr<void> _onUpdate(
      AddressUpdateRequested event,
      Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final response = await addressRemote.updateAddress(event.address);
      emit(AddressActionSuccess(response.message));
    } catch (e) {
      emit(AddressFailed(e.toString()));
    }
  }

  FutureOr<void> _onDelete(
      AddressDeleteRequested event,
      Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final response =
          await addressRemote.deleteAddress(event.addressId);
      emit(AddressActionSuccess(response.message));
    } catch (e) {
      emit(AddressFailed(e.toString()));
    }
  }
}