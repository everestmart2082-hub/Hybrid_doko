import 'package:dio/dio.dart';
import '../data/product_input_model.dart';

abstract class ProductEvent {}

class GetProducts extends ProductEvent {
  final int page;
  final int limit;
  final double? minPrice;
  final double? maxPrice;
  final String productCategory;
  final String deliveryCategory;
  final String searchText;
  final String brand;
  final int? rating;
  final int? stock;
  final String sortBy;
  final String vendorId;
  /// Server: `in_stock` | `out_of_stock` | empty
  final String stockFilter;

  GetProducts({
    this.page = 1,
    this.limit = 10,
    this.minPrice,
    this.maxPrice,
    this.productCategory = "",
    this.deliveryCategory = "",
    this.searchText = "",
    this.brand = "",
    this.rating,
    this.stock,
    this.sortBy = "default",
    this.vendorId = "all",
    this.stockFilter = "",
  });
}

class GetProductFilters extends ProductEvent {}

class GetProductDetail extends ProductEvent {
  final String id;

  GetProductDetail(this.id);
}

class AddProduct extends ProductEvent {
  final ProductInput input;
  final List<MultipartFile> files;

  AddProduct(this.input, this.files);
}

class EditProduct extends ProductEvent {
  final ProductInput input;
  final List<MultipartFile> files;
  final String productId;

  EditProduct(this.input, this.files, this.productId);
}

class DeleteProduct extends ProductEvent {
  final String id;

  DeleteProduct(this.id);
}