import 'package:dio/dio.dart';

import 'package:quickmartrider/core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../data/contact_model.dart';

class RiderContactsRemote {
  final DioClient dio;

  RiderContactsRemote({required this.dio});

  Future<RiderContactResponseModel> sendMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    final response = await dio.post(
      ApiEndpoints.riderMessage,
      FormData.fromMap({
        // Backend currently reads only `message` for /api/rider/message.
        "name": name,
        "email": email,
        "message": message,
      }),
    );

    final data = response is Map<String, dynamic>
        ? response
        : (response is Map ? response.cast<String, dynamic>() : <String, dynamic>{});

    return RiderContactResponseModel.fromJson(data);
  }
}

