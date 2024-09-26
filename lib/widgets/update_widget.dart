import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// Функция для показа диалога обновления
Future<bool> showUpdateDialog(BuildContext context) async {
  final localizations = AppLocalizations.of(context)!;
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.aua),
        content: Text(localizations.nv),
        actions: <Widget>[
          TextButton(
            child: Text(localizations.no),
            onPressed: () {
              Navigator.of(context).pop(false);  // Пользователь отказался
            },
          ),
          TextButton(
            child: Text(localizations.yes),
            onPressed: () {
              Navigator.of(context).pop(true);  // Пользователь согласился
            },
          ),
        ],
      );
    },
  ) ?? false;
}
