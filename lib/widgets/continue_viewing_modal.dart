import 'package:flutter/material.dart';

import 'package:AniFlim/l10n/app_localizations.dart';

void showAnimeStatusDialog({
  required BuildContext context,
  required String currentStatus,
  required VoidCallback continueViewing,
}) {
    final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(localizations.continueWatching, style: const TextStyle(color: Colors.white, fontSize: 20,),),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.no),
        ),
        TextButton(
          onPressed: () => continueViewing(),
          child: Text(localizations.yes),
        ),
      ],
    ),
  );
}