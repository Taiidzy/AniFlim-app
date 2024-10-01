import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
// import '../utils/constants.dart';

class FirebaseApi {
  static Timer? _timer;

  static Future<void> initNotifications() async {
    try {
      final _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("Token: $token");
        await sendToken(token);
        _scheduleTokenUpdate(token); // Запланируем обновление токена
      } else {
        print('FCM token is null');
      }
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  static Future<void> sendToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.102:5000/api/notification/token'),
        body: jsonEncode({"fcm_token": token}),
        headers: {"Content-Type": "application/json"},
      );

      final status = response.statusCode;
      if (status == 200) {
        print('Token updated successfully');
      } else if (status == 304) {
        print('Token already exists');
      } else {
        print('Failed to update token, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  static void _scheduleTokenUpdate(String token) {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 3)); // Переводим в МСК
    DateTime nextCall = DateTime(now.year, now.month, now.day, 0, 1); // Завтра 00:01

    if (now.isAfter(nextCall)) {
      nextCall = nextCall.add(Duration(days: 1)); // Если уже после 00:01, назначаем на завтра
    }

    Duration delay = nextCall.difference(now);

    _timer = Timer(delay, () {
      sendToken(token); // Вызываем функцию sendToken
      _scheduleTokenUpdate(token); // Запланируем следующий вызов
    });
  }
}