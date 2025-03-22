import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _autocontinue = false;
  bool _marathonMode = false;
  bool _autoSkipOpening = false;
  String _quality = 'hls_480';

  Locale get locale => _locale;
  bool get autocontinue => _autocontinue;
  bool get marathonMode => _marathonMode;
  bool get autoSkipOpening => _autoSkipOpening;
  String get quality => _quality;

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

    // Загрузка состояния марафона
    _marathonMode = prefs.getBool('_marathonMode') ?? false;

    _quality = prefs.getString('quality') ?? 'hls_480';

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
  
  // Сохранение и установка режима марафона
  Future<void> setMarathonMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marathonMode', value);
    _marathonMode = value;
    notifyListeners();
  }
  
  // Сохранение и установка режима марафона
  Future<void> setAutoSkipOpening(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSkipOpening', value);
    _autoSkipOpening = value;
    notifyListeners();
  }
  
  // Сохранение и установка режима марафона
  Future<void> setQuality(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quality', value);
    _quality = value;
    notifyListeners();
  }
}