import 'package:permission_handler/permission_handler.dart';

class Permision {
  static Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return; // Если разрешение уже предоставлено, ничего не делаем
    }

    // Проверка версии Android (API 33 и выше требуют явного запроса разрешения)
    if (await Permission.notification.request().isGranted) {
      print('Разрешение на уведомления предоставлено.');
    } else {
      print('Разрешение на уведомления не предоставлено.');
    }
  }
}
