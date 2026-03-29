import '../../../core/network/dio_client.dart';
import '../../product/data/simple_response_model.dart';
import '../data/checkout_request_model.dart';
import '../data/payment_query_model.dart';

class PaymentRemote {
  final DioClient dio;

  PaymentRemote({required this.dio});

  /// CHECKOUT
  Future<SimpleResponseModel> checkout(CheckoutRequestModel request) async {
    final response = await dio.post(
      '/api/user/checkout',
      request.toFormData(),
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }

  /// PAYMENT STATUS
  Future<SimpleResponseModel> checkPaymentStatus(PaymentQueryModel query) async {
    final response = await dio.get(
      '/api/user/payment',
      query: query.toQuery(),
    );

    return SimpleResponseModel.fromJson(response.data ?? response);
  }
}