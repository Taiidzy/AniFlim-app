import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:AniFlim/providers/locale_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';

class SettingsMenu extends StatelessWidget {
  final Map<String, dynamic> episodeInfo;
  const SettingsMenu({Key? key, required this.episodeInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.playerSettings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: isDarkTheme ? Colors.white54 : Colors.black54),
            SwitchListTile(
              title: Text(localizations.autocontinue, style: TextStyle(fontSize: 16, color: textColor)),
              value: localeProvider.autocontinue,
              onChanged: localeProvider.setAutocontinue,
            ),
            Divider(color: isDarkTheme ? Colors.white54 : Colors.black54),
            SwitchListTile(
              title: Text(localizations.marathonMode, style: TextStyle(fontSize: 16, color: textColor)),
              value: localeProvider.marathonMode,
              onChanged: localeProvider.setMarathonMode,
            ),
            Divider(color: isDarkTheme ? Colors.white54 : Colors.black54),
            SwitchListTile(
              title: Text(localizations.autoSkipOpening, style: TextStyle(fontSize: 16, color: textColor)),
              value: localeProvider.autoSkipOpening,
              onChanged: localeProvider.setAutoSkipOpening,
            ),
            const SizedBox(height: 20),
            Text(
              localizations.quality,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: localeProvider.quality,
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: textColor),
                onChanged: (String? newResolution) => localeProvider.setQuality(newResolution!),
                items: episodeInfo.keys
                    .where((key) => key.startsWith('hls_'))
                    .map<DropdownMenuItem<String>>((key) {
                  final label = key.replaceFirst('hls_', '') + 'p';
                  return DropdownMenuItem(
                    value: key,
                    child: Text(label, style: TextStyle(color: textColor)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
