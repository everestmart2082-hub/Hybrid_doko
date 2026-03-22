import 'package:equatable/equatable.dart';
import '../data/otp_model.dart';

abstract class RiderOrderEvent extends Equatable {
  const RiderOrderEvent();
  @override
  List<Object?> get props => [];
}

class RiderOrderFetchRequested extends RiderOrderEvent {
  final int page;
  final int limit;
  final String? searchText;
  final String? status;
  final String? deliveryCategory;

  const RiderOrderFetchRequested({
    this.page = 1,
    this.limit = 20,
    this.searchText,
    this.status,
    this.deliveryCategory,
  });

  @override
  List<Object?> get props => [page, limit, searchText ?? "", status ?? "", deliveryCategory ?? ""];
}

class RiderOrderGenerateOtp extends RiderOrderEvent {
  final GenerateOtpModel model;

  const RiderOrderGenerateOtp(this.model);

  @override
  List<Object?> get props => [model];
}

class RiderOrderDelivered extends RiderOrderEvent {
  final DeliverOrderOtpModel model;

  const RiderOrderDelivered(this.model);

  @override
  List<Object?> get props => [model];
}