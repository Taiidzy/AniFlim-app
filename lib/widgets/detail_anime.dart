import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

import 'package:AniFlim/models/anime_detail_model.dart';
import 'package:AniFlim/models/status_anime_model.dart';
import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
// import 'package:AniFlim/widgets/quality_dialog.dart';
import 'package:AniFlim/utils/constants.dart';
import 'package:AniFlim/api/user_api.dart';

// import 'continue_viewing_modal.dart';

class DetailAnime extends StatefulWidget {
  final AnimeDetail anime;

  const DetailAnime({super.key, required this.anime});

  @override
  _DetailAnimeState createState() => _DetailAnimeState();
}

class _DetailAnimeState extends State<DetailAnime> {
  AnimeStatusModel? _animeStatus;
  String? token;
  bool _isStatusLoaded = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);

    provider.getToken().then((token) {
      setState(() => this.token = token);
      _checkAnimeStatus();
    });
  }

  void _checkAnimeStatus() async {
    if (token == null) return;
    final int animeId = int.parse(widget.anime.id.toString());
    final status = await UserAPI.fetchStatusAnime(token!, animeId);
    // if (status.status != 'not') {
    //   showAnimeStatusDialog(
    //     context: context, 
    //     currentStatus: status.status ?? '',
    //     continueViewing:() => _continueViewing(),
    //   );
    // }
    setState(() {
      _animeStatus = status;
      _isStatusLoaded = true;
    });
  }
  
  // TODO: Сделать окно для отображения предложения просмотра

  /* 

  void _continueViewing() {
    Navigator.pop(context);
    print('Continue Viewing button pressed');
  }

  */


  Future<void> _updateList(String action) async {
    if (token == null) return;
    if (action == 'add') {
      await UserAPI.addStatusAnime(token!, int.parse(widget.anime.id.toString()));
    } else if (action == 'remove') {
      await UserAPI.deleteStatusAnime(token!, int.parse(widget.anime.id.toString()));
    } else {
      await UserAPI.updateStatusAnime(token!, action, int.parse(widget.anime.id.toString()));
    }
    _checkAnimeStatus();
  }

  // void _handleDownload() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return QualityDialog(animeName: widget.anime.name);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(storageApi + widget.anime.img),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDarkTheme 
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                        isDarkTheme 
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 2/3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        storageApi + widget.anime.img,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(height: 16.0),
                                  // _ListButton(
                                  //   label: 'Загрузить',
                                  //   icon: HugeIcons.strokeRoundedDownloadCircle02,
                                  //   onPressed: _handleDownload,
                                  // ),
                                  const SizedBox(height: 16.0),
                                  if (_isStatusLoaded && _animeStatus != null) 
                                    ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDarkTheme 
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isDarkTheme 
                                                ? Colors.white.withOpacity(0.1)
                                                : Colors.black.withOpacity(0.1),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16.0),
                                          child: _buildButtonRow(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              flex: 2,
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDarkTheme 
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDarkTheme 
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.anime.name,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: isDarkTheme ? Colors.white : Colors.black87,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Divider(color: isDarkTheme ? Colors.white24 : Colors.black12),
                                          _buildInfoRow(localizations.voiceover, widget.anime.voiceover),
                                          _buildInfoRow(localizations.outin, widget.anime.releaseDate),
                                          _buildInfoRow(localizations.ageRaiting, widget.anime.ageRaiting),
                                          _buildInfoRow(localizations.studio, 'AniLibria'),
                                          _buildGenres(localizations.genres, widget.anime.genres),
                                          _buildInfoRow(localizations.description, widget.anime.description),
                                        ],
                                      ),
                                    ),
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
              ),
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(storageApi + widget.anime.img),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDarkTheme 
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                        isDarkTheme 
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            storageApi + widget.anime.img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // _ListButton(
                        //   label: 'Загрузить',
                        //   icon: Icons.download,
                        //   onPressed: _handleDownload,
                        // ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDarkTheme 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDarkTheme 
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.anime.name,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: isDarkTheme ? Colors.white : Colors.black87,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Divider(color: isDarkTheme ? Colors.white24 : Colors.black12),
                                    _buildInfoRow(localizations.voiceover, widget.anime.voiceover),
                                    _buildInfoRow(localizations.outin, widget.anime.releaseDate),
                                    _buildInfoRow(localizations.ageRaiting, widget.anime.ageRaiting),
                                    _buildInfoRow(localizations.studio, 'AniLibria'),
                                    _buildGenres(localizations.genres, widget.anime.genres),
                                    _buildInfoRow(localizations.description, widget.anime.description),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_isStatusLoaded && _animeStatus != null) _buildButtonRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRect(
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
            child: ListTile(
              title: Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                  letterSpacing: 0.5,
                )
              ),
              subtitle: Text(
                value,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white60 : Colors.black54,
                  letterSpacing: 0.3,
                )
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenres(String label, String genres) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white70 : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: genres.split(',').map((genre) {
              return ClipRect(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        genre.trim(),
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    final localizations = AppLocalizations.of(context);
    final List<Widget> buttons = [];

    void addButton(Widget button) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(height: 16.0));
      }
      buttons.add(button);
    }

    if (_animeStatus!.status == 'not') {
      addButton(
        _ListButton(
          label: localizations.addtolist,
          icon: HugeIcons.strokeRoundedAddCircle,
          onPressed: () => _updateList('add'),
        ),
      );
    } else {
      if (_animeStatus!.status != 'watched') {
        addButton(
          _ListButton(
            label: localizations.watched,
            icon: HugeIcons.strokeRoundedPlay,
            onPressed: () => _updateList('watched'),
          ),
        );
      }
      if (_animeStatus!.status != 'watching') {
        addButton(
          _ListButton(
            label: localizations.watching,
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            onPressed: () => _updateList('watching'),
          ),
        );
      }
      if (_animeStatus!.status != 'planned') {
        addButton(
          _ListButton(
            label: localizations.planned,
            icon: HugeIcons.strokeRoundedTimeSchedule,
            onPressed: () => _updateList('planned'),
          ),
        );
      }
      addButton(
        _ListButton(
          label: localizations.removefromlist,
          icon: HugeIcons.strokeRoundedDelete02,
          onPressed: () => _updateList('remove'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }
}

class _ListButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ListButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkTheme 
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkTheme 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isDarkTheme ? Colors.white : Colors.black87,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _QualityButton extends StatelessWidget {
//   final String quality;
//   final VoidCallback onPressed;

//   const _QualityButton({
//     required this.quality,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
//     return ClipRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//         child: Container(
//           decoration: BoxDecoration(
//             color: isDarkTheme 
//               ? Colors.black.withOpacity(0.3)
//               : Colors.white.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isDarkTheme 
//                 ? Colors.white.withOpacity(0.1)
//                 : Colors.black.withOpacity(0.1),
//             ),
//           ),
//           child: ElevatedButton(
//             onPressed: onPressed,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               foregroundColor: isDarkTheme ? Colors.white : Colors.black87,
//               minimumSize: const Size.fromHeight(48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text(
//               quality,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
