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
    final response = await dio.post(
      '/user/address/all',
      FormData.fromMap({
        "page": page,
        "limit": limit,
      }),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    if (data["success"] == true) {
      return (data["message"] as List?)
              ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [];
    } else {
      throw Exception(data["message"] ?? 'Failed to fetch addresses');
    }
  }

  // ADD
  Future<SimpleResponseModel> addAddress(AddressRequestModel address) async {
    final response = await dio.post(
      '/user/address/add',
      address.toFormData(),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }

  // UPDATE
  Future<SimpleResponseModel> updateAddress(AddressRequestModel address) async {
    final response = await dio.post(
      '/user/address/update',
      address.toFormData(),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }

  // DELETE
  Future<SimpleResponseModel> deleteAddress(String addressId) async {
    final formData = FormData.fromMap({"address id": addressId});
    final response = await dio.post(
      '/user/address/delete',
      formData,
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});
    return SimpleResponseModel.fromJson(data);
  }
}
