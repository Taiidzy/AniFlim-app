import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/anime_detail_model.dart';
import '../providers/user_provider.dart';

class DetailAnime extends StatefulWidget {
  final AnimeDetail anime;

  const DetailAnime({super.key, required this.anime});

  @override
  _DetailAnimeState createState() => _DetailAnimeState();
}

class _DetailAnimeState extends State<DetailAnime> {
  bool _isWatching = false;
  bool _isWatched = false;
  String? token;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    
    provider.getToken().then((token) {
      setState(() => this.token = token);
      _checkAnimeStatus();
    });
  }

  void _checkAnimeStatus() {
    print('Checking anime status for ${widget.anime.id}');
  }

  Future<void> _updateList(String action) async {
    print('Updating list with action: $action');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
          // TODO: Добавить логику работы с кнопками
          // if (token != null) _buildButtonRow(context, localizations),
        ],
      ),
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

  Widget _buildButtonRow(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        if (!_isWatching && !_isWatched)
          _ListButton(
            label: localizations.addtolist,
            icon: Icons.add,
            onPressed: () => _updateList('add'),
          ),
        if (_isWatching)
          _ListButton(
            label: localizations.watched,
            icon: Icons.check,
            onPressed: () => _updateList('watched'),
          ),
        if (_isWatching || _isWatched)
          _ListButton(
            label: localizations.removefromlist,
            icon: Icons.delete,
            onPressed: () => _updateList('remove'),
          ),
        if (!_isWatching && _isWatched)
          _ListButton(
            label: localizations.watching,
            icon: Icons.play_arrow,
            onPressed: () => _updateList('watching'),
          ),
        const SizedBox(height: 16.0),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
