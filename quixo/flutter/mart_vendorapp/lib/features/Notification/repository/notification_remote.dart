
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/failures/failures.dart';
import 'package:quickmartvender/core/network/dio_client.dart';

import '../data/notification_model.dart';

class NotificationRemote {

  final DioClient dio;

  NotificationRemote({required this.dio});

  Future<List<NotificationModel>> getNotifications(
      int page,
      int limit,
  ) async {

    Map<String, dynamic> map = await dio.post(
      ApiEndpoints.notification,
      {
        "page": page,
        "limit": limit,
      },
    );

    checkSuccess(map);

    List list = map["message"];

    return list
        .map((e) => NotificationModel.fromMap(e))
        .toList();
  }

}