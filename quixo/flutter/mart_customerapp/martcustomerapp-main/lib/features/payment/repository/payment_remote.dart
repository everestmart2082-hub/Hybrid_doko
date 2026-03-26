import '../../../core/network/dio_client.dart';
import '../../product/data/simple_response_model.dart';
import '../data/checkout_request_model.dart';
import '../data/payment_query_model.dart';

class PaymentRemote {
  final DioClient dio;

  PaymentRemote({required this.dio});

  /// CHECKOUT
  Future<SimpleResponseModel> checkout(
      CheckoutRequestModel request) async {
    final response = await dio.post(
      '/user/checkout',
      request.toJson(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }

  /// PAYMENT STATUS
  Future<SimpleResponseModel> checkPaymentStatus(
      PaymentQueryModel query) async {
    final response = await dio.get(
      '/user/payment',
      query: query.toQuery(),
    );

    return SimpleResponseModel.fromJson(response.data);
  }
}