import 'package:flutter/material.dart';

import 'package:AniFlim/l10n/app_localizations.dart';

String calculateTotalTime(int? totalTime, BuildContext context) {
  final localizations = AppLocalizations.of(context);
  if (totalTime == null) {
    return '';
  }

  if (totalTime == 0) {
    return '0 Секунд';
  } else if (totalTime < 60) {
    // Секунды
    int seconds = totalTime;
    String secondsLabel = localizations.seconds;
    if (seconds % 10 == 1 && seconds % 100 != 11) {
      secondsLabel = localizations.second;
    } else if (seconds % 10 >= 2 &&
        seconds % 10 <= 4 &&
        (seconds % 100 < 10 || seconds % 100 >= 20)) {
      secondsLabel = localizations.secondss;
    }
    return '$seconds $secondsLabel';
  } else if (totalTime < 3600) {
    // Минуты
    int minutes = totalTime ~/ 60;
    String minutesLabel = localizations.minutes;
    if (minutes % 10 == 1 && minutes % 100 != 11) {
      minutesLabel = localizations.minute;
    } else if (minutes % 10 >= 2 &&
        minutes % 10 <= 4 &&
        (minutes % 100 < 10 || minutes % 100 >= 20)) {
      minutesLabel = localizations.minutess;
    }
    return '$minutes $minutesLabel';
  } else {
    // Часы
    int hours = totalTime ~/ 3600;
    String hourLabel = localizations.hours;
    if (hours % 10 == 1 && hours % 100 != 11) {
      hourLabel = localizations.hour;
    } else if (hours % 10 >= 2 &&
        hours % 10 <= 4 &&
        (hours % 100 < 10 || hours % 100 >= 20)) {
      hourLabel = localizations.hourss;
    }
    return '$hours $hourLabel';
  }
}
