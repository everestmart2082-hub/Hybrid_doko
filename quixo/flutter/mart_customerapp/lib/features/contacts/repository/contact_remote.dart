import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../payment/data/simple_response_model.dart';

class ContactRemote {
  final DioClient dio;

  ContactRemote({required this.dio});

  /// Backend: POST `/api/user/sendmessage`
  ///
  /// Backend expects form-data field `message`.
  Future<SimpleResponseModel> sendMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    final formData = FormData.fromMap({
      // Backend currently only reads `message`, but sending these helps match UI.
      "name": name,
      "email": email,
      "message": message,
    });

    final response = await dio.post(
      '/user/sendmessage',
      formData,
    );

    final msg = (response is Map && response["message"] != null)
        ? response["message"].toString()
        : '';

    final successVal =
        (response is Map) ? (response["status"] ?? response["success"]) : null;

    final success = switch (successVal) {
      final bool b => b,
      final String s => s.toLowerCase() == 'true' || s == '1',
      final num n => n != 0,
      _ => false,
    };

    return SimpleResponseModel(
      success: success,
      message: msg,
    );
  }
}

