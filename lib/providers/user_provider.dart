import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:AniFlim/models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _cachedToken; // Кеш токена
  

  // Синхронный геттер для быстрого доступа
  String? get currentToken => _cachedToken;
  User? get currentUser => _currentUser;

  UserProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('token');
    notifyListeners();
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (token != null) {
      await prefs.setString('token', token);
      _cachedToken = token; // Сохраняем в кеш
    } else {
      await prefs.remove('token');
      _cachedToken = null; // Очищаем кеш
      _currentUser = null;
    }
    
    notifyListeners();
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken; // Возвращаем из кеша
    
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('token'); // Кешируем при первом запросе
    return _cachedToken;
  }

  void updateUser(User newUser) {
    _currentUser = newUser;
    notifyListeners(); // Уведомляем слушателей об изменении
  }
}
