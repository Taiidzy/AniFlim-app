import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthAPI {
  // Логин пользователя
  static Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
          Uri.parse('$apiBaseUrl/user/login'),
          body: json.encode({"username": username, "password": password}),
          headers: {"Content-Type": "application/json"}
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
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
  static Future<bool> register(String username, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        body: json.encode({"username": username, "password": password, "email": email}),
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