import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    settings:  initializationSettings,
  );
}

Future<void> showNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'default_channel', 
    'Default', 
    importance: Importance.max,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id: 0, 
    title: title, 
    body: body, 
    notificationDetails: details,
  );
}