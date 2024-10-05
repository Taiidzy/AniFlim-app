import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationAPI {

  Future<List<NotificationItem>> fetchNotifications() async {
    log('Request to server...', name: 'NotificationApi');
    final response = await http.post(
      Uri.parse('$apiBaseUrl/notifications'),
      headers: {"Content-Type": "application/json"}
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => NotificationItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}