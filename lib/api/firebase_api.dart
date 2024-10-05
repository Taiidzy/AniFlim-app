import 'dart:convert';
import 'dart:async';
import 'dart:developer'; // Для логгирования
import 'package:AniFlim/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class FirebaseApi {
  static Future<void> initNotifications() async {
    try {
      final _firebaseMessaging = FirebaseMessaging.instance;
      await _firebaseMessaging.requestPermission();

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        log("Token received: $token", name: 'FirebaseApi');
        await sendToken(token);
        scheduleDailyTask(); // Запускаем задачу
      } else {
        log('FCM token is null', name: 'FirebaseApi');
      }
    } catch (e) {
      log('Failed to initialize notifications: $e', name: 'FirebaseApi', error: e);
    }
  }

  static Future<void> sendToken(String token) async {
    try {
      log('Sending token to server...', name: 'FirebaseApi');
      final response = await http.post(
        Uri.parse('$apiBaseUrl/notification/token'),
        body: jsonEncode({"fcm_token": token}),
        headers: {"Content-Type": "application/json"},
      );

      final status = response.statusCode;
      if (status == 200) {
        log('Token updated successfully', name: 'FirebaseApi');
      } else if (status == 304) {
        log('Token already exists', name: 'FirebaseApi');
      } else {
        log('Failed to update token, status code: ${response.statusCode}', name: 'FirebaseApi');
      }
    } catch (e) {
      log('Error sending token: $e', name: 'FirebaseApi', error: e);
    }
  }

  // Функция планировщика задач
  static void scheduleDailyTask() {
    tz.initializeTimeZones();
    final moscow = tz.getLocation('Europe/Moscow');

    final now = tz.TZDateTime.now(moscow);
    final nextRunTime = tz.TZDateTime(moscow, now.year, now.month, now.day, 0, 1);

    // Если текущее время уже больше 00:01, то назначаем задачу на следующий день
    if (now.isAfter(nextRunTime)) {
      final nextRunTimeTomorrow = nextRunTime.add(Duration(days: 1));
      final timeUntilNextRun = nextRunTimeTomorrow.difference(now);
      log('Scheduling task for tomorrow at 00:01 MSK', name: 'FirebaseApi');
      Timer(timeUntilNextRun, () => runTaskPeriodically());
    } else {
      final timeUntilNextRun = nextRunTime.difference(now);
      log('Scheduling task for today at 00:01 MSK', name: 'FirebaseApi');
      Timer(timeUntilNextRun, () => runTaskPeriodically());
    }
  }

  // Функция для периодического выполнения задачи
  static void runTaskPeriodically() {
    log('Starting periodic task every 24 hours', name: 'FirebaseApi');
    Timer.periodic(Duration(days: 1), (timer) async {
      log('Executing scheduled task', name: 'FirebaseApi');
      await initNotifications();
    });
  }
}
