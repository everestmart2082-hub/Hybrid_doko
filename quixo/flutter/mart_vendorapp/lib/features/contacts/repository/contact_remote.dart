import 'package:dio/dio.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

class ContactRemote {
  final DioClient dio;

  ContactRemote({required this.dio});

  Future<void> sendToAdmin({
    required String name,
    required String email,
    required String message,
  }) async {
    final res = await dio.post(
      ApiEndpoints.contactAdmin,
      FormData.fromMap({
        'name': name,
        'email': email,
        'message': message,
      }),
    );
    if (res is Map && res['success'] != true) {
      throw Exception(res['message']?.toString() ?? 'Failed to send');
    }
  }
}
