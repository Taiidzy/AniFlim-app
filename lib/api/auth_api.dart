import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:AniFlim/utils/constants.dart';

class AuthAPI {
  // Логин пользователя
  static Future<String?> login(String login, String password, bool rememberMe) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "login": login,
          "password": password,
          "rememberMe": rememberMe
        }),
      );

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
  static Future<int> register(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        body: json.encode({"login": login, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      // Декодируем ответ от сервера и выводим в консоль
      final decodedResponse = utf8.decode(response.bodyBytes);
      print('Response from server: $decodedResponse');
      print(response.statusCode);

      return response.statusCode;
    } catch (e) {
      print('Exception caught: $e');
      return 0;
    }
  }
}