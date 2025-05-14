import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _autocontinue = false;
  bool _marathonMode = false;
  bool _autoSkipOpening = false;
  String _quality = 'hls_480';
  double _playbackSpeed = 1.0;
  String _qualityDownload = '480p';

  Locale get locale => _locale;
  bool get autocontinue => _autocontinue;
  bool get marathonMode => _marathonMode;
  bool get autoSkipOpening => _autoSkipOpening;
  String get quality => _quality;
  double get playbackSpeed => _playbackSpeed;
  String get qualityDownload => _qualityDownload;

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

    _playbackSpeed = prefs.getDouble('playbackSpeed') ?? 1.0;

    _qualityDownload = prefs.getString('qualityDownload') ?? '480p';

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
  void setAutocontinue(bool value) {
    _autocontinue = value;
    notifyListeners();
  }
  
  // Сохранение и установка режима марафона
  void setMarathonMode(bool value) {
    _marathonMode = value;
    notifyListeners();
  }
  
  // Сохранение и установка режима марафона
  void setAutoSkipOpening(bool value) {
    _autoSkipOpening = value;
    notifyListeners();
  }
  
  // Сохранение и установка режима марафона
  void setQuality(String value) {
    _quality = value;
    notifyListeners();
  }

  void setPlaybackSpeed(double value) {
    _playbackSpeed = value;
    notifyListeners();
  }

  void setQualityDownload(String value) {
    _qualityDownload = value;
    notifyListeners();
  }
}