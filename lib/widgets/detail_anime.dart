import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/models/anime_detail_model.dart';
import 'package:AniFlim/models/status_anime_model.dart';
import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Порог можно регулировать по вашим потребностям
        if (constraints.maxWidth > 800) {
          // Вид для ПК: изображение слева, информация справа
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение занимает примерно 1/3 ширины
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          storageApi + widget.anime.img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 16.0, height: 16.0),
                      if (_isStatusLoaded && _animeStatus != null) _buildButtonRow(),
                    ]
                  )
                ),
                const SizedBox(width: 16.0),
                // Информация – оставшаяся часть
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.anime.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Divider(),
                          _buildInfoRow(localizations.voiceover, widget.anime.voiceover),
                          _buildInfoRow(localizations.outin, widget.anime.releaseDate),
                          _buildInfoRow(localizations.ageRaiting, widget.anime.ageRaiting),
                          _buildInfoRow(localizations.studio, 'AniLibria'),
                          _buildGenres(localizations.genres, widget.anime.genres),
                          _buildInfoRow(localizations.description, widget.anime.description),
                          // Если нужна кнопочная панель, можно добавить вызов _buildButtonRow(...)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Вид для мобильных устройств – оригинальный Column
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://anilibria.top${widget.anime.img}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.anime.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Divider(),
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
                // Если требуется кнопочная панель, можно ее добавить здесь
                if (_isStatusLoaded && _animeStatus != null) _buildButtonRow(),
              ],
            ),
          );
        }
      },
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildGenres(String label, String genres) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: genres.split(',').map((genre) {
          return Chip(label: Text(genre.trim()));
        }).toList(),
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
    return SizedBox(
      width: double.infinity, // Занимаем всю доступную ширину
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // Фиксируем минимальную высоту
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
