import 'dart:io';

import 'package:flutter/material.dart';

class Resolution {
  static getGridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      if (width > 1600) return 8;
      if (width > 1200) return 6;
      if (width > 900) return 5;
      return 4;
    } else {
      return width > 600 ? 3 : 2;
    }
  }

  static getChildAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Platform.isMacOS || Platform.isWindows) {
      return 0.69; // Увеличим карточки на ПК
    } else if (width > 400) {
      return 0.60; // Для планшетов и больших телефонов
    } else {
      return 0.50; // Для обычных телефонов
    }
  }
}
