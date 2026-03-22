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
  });
}

class GetProductDetail extends ProductEvent {
  final String id;

  GetProductDetail(this.id);
}

class AddProduct extends ProductEvent {
  final dynamic input;

  AddProduct(this.input);
}

class EditProduct extends ProductEvent {
  final dynamic input;

  EditProduct(this.input);
}

class DeleteProduct extends ProductEvent {
  final String id;

  DeleteProduct(this.id);
}