import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/wishlist_query_model.dart';
import '../repository/wishlist_remote.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRemote wishlistRemote;

  WishlistBloc(this.wishlistRemote) : super(WishlistInitial()) {
    on<WishlistFetchRequested>(_onFetch);
    on<WishlistAddItemRequested>(_onAdd);
    on<WishlistRemoveItemRequested>(_onRemove);
  }

  FutureOr<void> _onFetch(
      WishlistFetchRequested event,
      Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final items = await wishlistRemote.getWishlist(event.query);
      emit(WishlistLoaded(items));
    } catch (e) {
      emit(WishlistFailed(e.toString()));
    }
  }

  FutureOr<void> _onAdd(
      WishlistAddItemRequested event,
      Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final response = await wishlistRemote.addItem(event.productId);
      emit(WishlistActionSuccess(response.message));
      add(const WishlistFetchRequested(WishlistQueryModel()));
    } catch (e) {
      emit(WishlistFailed(e.toString()));
    }
  }

  FutureOr<void> _onRemove(
      WishlistRemoveItemRequested event,
      Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final response = await wishlistRemote.removeItem(event.productId);
      emit(WishlistActionSuccess(response.message));
      add(const WishlistFetchRequested(WishlistQueryModel()));
    } catch (e) {
      emit(WishlistFailed(e.toString()));
    }
  }
}