import '../../../core/network/dio_client.dart';
import '../data/notification_model.dart';
import '../data/notification_query_model.dart';

class NotificationRemote {
  final DioClient dio;

  NotificationRemote({required this.dio});

  Future<List<NotificationModel>> getNotifications(
      NotificationQueryModel query) async {
    final response = await dio.get(
      '/api/user/notification',
      query: query.toJson(),
    );

    final data = response.data ?? response;

    if (data["success"] == true) {
      return (data["message"] as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data["message"]);
    }
  }
}