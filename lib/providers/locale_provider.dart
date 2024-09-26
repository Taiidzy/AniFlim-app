import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _autocontinue = false;
  bool _HEVC = false;

  Locale get locale => _locale;
  bool get autocontinue => _autocontinue;
  bool get HEVC => _HEVC;

  LocaleProvider() {
    _loadPreferences();
  }

  // Метод для загрузки всех настроек из SharedPreferences
  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Загрузка сохранённого языка
    String? languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);

    // Загрузка сохранённого состояния авто-продолжения
    _autocontinue = prefs.getBool('autocontinue') ?? false;

    // Загрузка состояния HEVC
    _HEVC = prefs.getBool('_HEVCEnabled') ?? false;

    notifyListeners(); // Уведомляем всех слушателей после загрузки настроек
  }

  // Сохранение и установка языка
  void setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', languageCode);
  }

  // Сохранение и установка авто-продолжения
  Future<void> setAutocontinue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autocontinue', value);
    _autocontinue = value;
    notifyListeners();
  }

  // Сохранение и установка HEVC
  Future<void> setHEVC(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_HEVCEnabled', value);
    _HEVC = value;
    notifyListeners();
  }
}
