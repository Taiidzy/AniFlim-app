import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class Notifications {

  static Future<void> showNewAnimeNotification(String animeName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'new_anime',
      'Новое аниме',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      2,
      'Новое аниме',
      'Аниме "$animeName" теперь можно посмотреть.',
      platformChannelSpecifics,
    );
  }
}