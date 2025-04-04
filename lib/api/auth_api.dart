import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthAPI {
  // Логин пользователя
  static Future<String?> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"login": login, "password": password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        return token;
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }

  // Регистрация пользователя
  static Future<bool> register(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        body: json.encode({"login": login, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      // Логирование ответа
      print('Register Response status: ${response.statusCode}');
      print('Register Response body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Exception caught: $e');
      return false;
    }
  }
}