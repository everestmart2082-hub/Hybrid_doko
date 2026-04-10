import 'package:equatable/equatable.dart';

class OrderQueryModel extends Equatable {
  final int page;
  final int limit;
  final String? search;
  final String? status;
  final String? deliveryCategory;

  const OrderQueryModel({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.deliveryCategory,
  });

  Map<String, dynamic> toQuery() {
    return {
      "page": page,
      "limit": limit,
      if (search != null) "search": search,
      if (status != null) "status": status,
      if (deliveryCategory != null)
        "delivary category": deliveryCategory,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "page": page,
      "limit": limit,
      if (search != null) "search": search,
      if (status != null) "status": status,
      if (deliveryCategory != null) "delivary category": deliveryCategory,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  Map<String, dynamic> toFormData() {
    return {
      "page": page,
      "limit": limit,
      if (search != null) "search": search,
      if (status != null) "status": status,
      if (deliveryCategory != null) "delivary category": deliveryCategory,
    };
  }

  @override
  List<Object?> get props =>
      [page, limit, search, status, deliveryCategory];
}