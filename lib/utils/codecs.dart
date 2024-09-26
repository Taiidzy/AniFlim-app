import 'package:flutter/services.dart';

class Codecs {
  static const platform = MethodChannel('space.aniflim/device_info');

  // Вызов нативного метода для получения списка кодеков
  static Future<List<String>> getSupportedVideoCodecs() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getSupportedCodecs');
      return List<String>.from(result);
    } on PlatformException catch (e) {
      print("Ошибка получения кодеков: '${e.message}'.");
      return [];
    }
  }
}
