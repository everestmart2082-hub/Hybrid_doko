import 'package:equatable/equatable.dart';

import '../data/wishlist_model.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;

  const WishlistLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class WishlistActionSuccess extends WishlistState {
  final String message;

  const WishlistActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistFailed extends WishlistState {
  final String message;

  const WishlistFailed(this.message);

  @override
  List<Object?> get props => [message];
}