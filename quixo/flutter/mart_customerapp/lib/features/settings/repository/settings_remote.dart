import '../../../core/network/dio_client.dart';
import '../../product/data/simple_response_model.dart';
import '../data/settings_request_models.dart';

class SettingsRemote {
  final DioClient dio;

  SettingsRemote({required this.dio});

  Future<SimpleResponseModel> sendMessage(SendMessageRequestModel request) async {
    final response = await dio.post(
      '/user/sendmessage',
      request.toFormData(),
    );
    // The server returns {"status": true, "message": "..."} for sendmessage
    // We handle "status" or "success" in parsing loosely or map it
    final data = response.data ?? response;
    return SimpleResponseModel(
      success: data['status'] ?? data['success'] ?? false,
      message: data['message'] ?? '',
    );
  }

  Future<SimpleResponseModel> submitProductReview(ProductReviewRequestModel request) async {
    final response = await dio.post(
      '/user/review',
      request.toFormData(),
    );
    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  Future<SimpleResponseModel> submitProductRating(ProductRatingRequestModel request) async {
    final response = await dio.post(
      '/user/product/rating',
      request.toFormData(),
    );
    return SimpleResponseModel.fromJson(response.data ?? response);
  }
}
