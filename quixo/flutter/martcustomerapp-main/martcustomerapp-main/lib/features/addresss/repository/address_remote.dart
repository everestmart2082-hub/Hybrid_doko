import 'package:quickmartcustomer/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/address_model.dart';
import '../data/address_request_model.dart';
import '../../product/data/simple_response_model.dart';

class AddressRemote {
  final DioClient dio;

  AddressRemote({required this.dio});

  // GET ALL
  Future<List<AddressModel>> getAllAddresses({
    required int page,
    required int limit,
  }) async {
    final response = await dio.post(
      ApiEndpoints.getAllAddresses,
      {
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data;

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => AddressModel.fromJson(e))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  // ADD
  Future<SimpleResponseModel> addAddress(
      AddressRequestModel address) async {
    final response = await dio.post(
      ApiEndpoints.addAddress,
      address.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  // UPDATE
  Future<SimpleResponseModel> updateAddress(
      AddressRequestModel address) async {
    final response = await dio.post(
      ApiEndpoints.updateAddress,
      address.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  // DELETE
  Future<SimpleResponseModel> deleteAddress(
      String addressId) async {
    final response = await dio.delete(
      ApiEndpoints.deleteAddress,
      {"address_id": addressId},
    );

    return SimpleResponseModel.fromJson(response.data);
  }
}