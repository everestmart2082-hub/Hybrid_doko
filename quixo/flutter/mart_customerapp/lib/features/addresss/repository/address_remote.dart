import 'package:dio/dio.dart';

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
    final response = await dio.get(
      '/api/user/address/all',
      query: {
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data ?? response;

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }

  // ADD
  Future<SimpleResponseModel> addAddress(AddressRequestModel address) async {
    final response = await dio.post(
      '/api/user/address/add',
      address.toFormData(),
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  // UPDATE
  Future<SimpleResponseModel> updateAddress(AddressRequestModel address) async {
    final response = await dio.post(
      '/api/user/address/update',
      address.toFormData(),
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  // DELETE
  Future<SimpleResponseModel> deleteAddress(String addressId) async {
    final formData = FormData.fromMap({"address id": addressId});
    final response = await dio.post(
      '/api/user/address/delete',
      formData,
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }
}