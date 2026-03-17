import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/cart_remote.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRemote cartRemote;

  CartBloc(this.cartRemote) : super(CartInitial()) {
    on<CartFetchRequested>(_onFetch);
    on<CartAddRequested>(_onAdd);
    on<CartRemoveRequested>(_onRemove);
  }

  FutureOr<void> _onFetch(
      CartFetchRequested event,
      Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await cartRemote.getCartItems(event.query);
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartFailed(e.toString()));
    }
  }


  FutureOr<void> _onAdd(
      CartAddRequested event,
      Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final response =
          await cartRemote.addToCart(event.request);
      emit(CartActionSuccess(response.message));
    } catch (e) {
      emit(CartFailed(e.toString()));
    }
  }

  FutureOr<void> _onRemove(
      CartRemoveRequested event,
      Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final response =
          await cartRemote.removeFromCart(event.cartId);
      emit(CartActionSuccess(response.message));
    } catch (e) {
      emit(CartFailed(e.toString()));
    }
  }
}