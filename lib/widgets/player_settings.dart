import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

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

    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme 
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.playerSettings,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDarkTheme 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                localizations.autocontinue,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              value: localeProvider.autocontinue,
                              onChanged: localeProvider.setAutocontinue,
                            ),
                            Divider(
                              color: isDarkTheme ? Colors.white24 : Colors.black12,
                              height: 1,
                            ),
                            SwitchListTile(
                              title: Text(
                                localizations.marathonMode,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              value: localeProvider.marathonMode,
                              onChanged: localeProvider.setMarathonMode,
                            ),
                            Divider(
                              color: isDarkTheme ? Colors.white24 : Colors.black12,
                              height: 1,
                            ),
                            SwitchListTile(
                              title: Text(
                                localizations.autoSkipOpening,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              value: localeProvider.autoSkipOpening,
                              onChanged: localeProvider.setAutoSkipOpening,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.playbackSpeed,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDarkTheme 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<double>(
                          value: localeProvider.playbackSpeed,
                          isExpanded: true,
                          dropdownColor: isDarkTheme 
                            ? Colors.black.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white70 : Colors.black87,
                            letterSpacing: 0.5,
                          ),
                          underline: const SizedBox(),
                          onChanged: (double? newSpeed) {
                            if (newSpeed != null) {
                              localeProvider.setPlaybackSpeed(newSpeed);
                            }
                          },
                          items: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
                            return DropdownMenuItem(
                              value: speed,
                              child: Text('${speed}x'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.quality,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDarkTheme 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<String>(
                          value: localeProvider.quality,
                          isExpanded: true,
                          dropdownColor: isDarkTheme 
                            ? Colors.black.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white70 : Colors.black87,
                            letterSpacing: 0.5,
                          ),
                          underline: const SizedBox(),
                          onChanged: (String? newResolution) {
                            if (newResolution != null) {
                              localeProvider.setQuality(newResolution);
                            }
                          },
                          items: episodeInfo.keys
                              .where((key) => key.startsWith('hls_'))
                              .map<DropdownMenuItem<String>>((key) {
                            final label = key.replaceFirst('hls_', '') + 'p';
                            return DropdownMenuItem(
                              value: key,
                              child: Text(label),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
