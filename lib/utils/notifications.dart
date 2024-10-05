import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class Notifications {

  static Future<void> showNotification(String type, String text) async {
    if (type == 'new_anime') {
      await showNewAnimeNotification(text);
    } else if (type == 'new_episode') {
      await showNewEpisodeNotification(text);
    } else if (type == 'update') {
      await showUpdateNotification(text);
    } else {
      print('Unknown notification type: $type');
    }
  }

  static Future<void> showNewAnimeNotification(String text) async {
    String animeName = text.substring(0, text.indexOf(','));
    String animeId = text.substring(text.indexOf(',') + 1);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_anime',
      'Новое аниме',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Передаем animeId с префиксом "anime_"
    await flutterLocalNotificationsPlugin.show(
      2,
      'Новое аниме',
      'Аниме "$animeName" теперь можно посмотреть.',
      platformChannelSpecifics,
      payload: 'anime_$animeId', // Уникальный payload для аниме
    );
  }

  static Future<void> showNewEpisodeNotification(String text) async {
    String animeName = text.substring(0, text.indexOf(','));
    String episode = text.substring(text.indexOf(',') + 1);
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'new_episode',
      'Новый эпизод',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      3,
      'Новая серия',
      'Для аниме "$animeName" вышла новая серия. Эпизод $episode.',
      platformChannelSpecifics,
    );
  }

  static Future<void> showUpdateNotification(String version) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'update',
      'Обновление',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      4,
      'Обновление',
      'Вышла новая версия приложения: $version',
      platformChannelSpecifics,
    );
  }
}