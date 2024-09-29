import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lists_model.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  UserProvider();

  // Метод для установки пользователя и списков
  void setUser(User? user, {UserListsModel? userLists}) async {
    if (user != null) {
      _user = User(
        id: user.id,
        username: user.username,
        avatar: user.avatar,
        // all_watched: user.all_watched ?? '', // Используем пустую строку по умолчанию
        // all_watching: user.all_watching ?? '', // Используем пустую строку по умолчанию
        userLists: userLists ?? user.userLists,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', user.id);
      prefs.setString('username', user.username);
      prefs.setString('avatar', user.avatar);

      if (userLists != null) {
        prefs.setString('watched_list', jsonEncode(userLists.watched));
        prefs.setString('watching_list', jsonEncode(userLists.watching));
      }
    } else {
      _user = null;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user_id');
      prefs.remove('username');
      prefs.remove('avatar');
      prefs.remove('watched_list');
      prefs.remove('watching_list');
    }

    notifyListeners();
  }

  // Метод для установки только списков
  void setUserLists(UserListsModel? userLists) async {
    if (_user != null && userLists != null) {
      _user = User(
        id: _user!.id,
        username: _user!.username,
        avatar: _user!.avatar,
        // all_watched: _user!.all_watched ?? '', // Используем пустую строку по умолчанию
        // all_watching: _user!.all_watching ?? '', // Используем пустую строку по умолчанию
        userLists: userLists,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('watched_list', jsonEncode(userLists.watched));
      prefs.setString('watching_list', jsonEncode(userLists.watching));

      notifyListeners();
    }
  }

  // Метод для загрузки пользователя и списков из SharedPreferences
  Future<void> loadUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final username = prefs.getString('username');
    final avatar = prefs.getString('avatar');
    // final all_watched = prefs.getString('all_watched') ?? '';
    // final all_watching = prefs.getString('all_watching') ?? '';

    if (userId != null && username != null && avatar != null) {
      final watchedJson = prefs.getString('watched_list');
      final watchingJson = prefs.getString('watching_list');

      List<AnimeItem> watched = [];
      List<AnimeItem> watching = [];

      if (watchedJson != null) {
        try {
          final List<dynamic> watchedList = jsonDecode(watchedJson);
          watched = watchedList.map((item) => AnimeItem.fromJson(item)).toList();
        } catch (e) {
          // Обработка ошибок JSON декодирования
          print('Error decoding watched list: $e');
        }
      }

      if (watchingJson != null) {
        try {
          final List<dynamic> watchingList = jsonDecode(watchingJson);
          watching = watchingList.map((item) => AnimeItem.fromJson(item)).toList();
        } catch (e) {
          // Обработка ошибок JSON декодирования
          print('Error decoding watching list: $e');
        }
      }

      UserListsModel userLists = UserListsModel(watched: watched, watching: watching);

      _user = User(
        id: userId,
        username: username,
        avatar: avatar,
        // all_watched: all_watched,
        // all_watching: all_watching,
        userLists: userLists,
      );
      notifyListeners();
    }
  }
}
