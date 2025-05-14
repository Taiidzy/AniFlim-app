import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:AniFlim/models/franchise_model.dart';
import 'package:AniFlim/api/anime_api.dart';
import 'package:AniFlim/widgets/anime_card.dart';
import 'package:AniFlim/utils/resolution.dart';
import 'package:AniFlim/l10n/app_localizations.dart';

class RelatedSeasons extends StatefulWidget {
  final String animeId;
  final String currentAnimeName;

  const RelatedSeasons({
    Key? key,
    required this.animeId,
    required this.currentAnimeName,
  }) : super(key: key);

  @override
  State<RelatedSeasons> createState() => _RelatedSeasonsState();
}

class _RelatedSeasonsState extends State<RelatedSeasons> {
  final AnimeAPI _api = AnimeAPI();
  late Future<List<Franchise>> _franchiseFuture;

  @override
  void initState() {
    super.initState();
    _franchiseFuture = _api.fetchFranchise(widget.animeId);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return FutureBuilder<List<Franchise>>(
      future: _franchiseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${localizations.loadingError}: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              localizations.noRelatedSeasons,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final franchise = snapshot.data!.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations.franchise}: ${franchise.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildInfoChip('${localizations.years}: ${franchise.firstYear} - ${franchise.lastYear}'),
                      _buildInfoChip('${localizations.episodes}: ${franchise.totalEpisodes}'),
                      _buildInfoChip('${localizations.duration}: ${franchise.totalDuration}'),
                      _buildInfoChip('${localizations.seasons}: ${franchise.totalReleases}'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Resolution.getGridCount(context),
                  childAspectRatio: Resolution.getChildAspectRatio(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: franchise.franchiseReleases.length,
                itemBuilder: (context, index) {
                  final release = franchise.franchiseReleases[index];
                  return AnimeCard(
                    anime: release.release,
                    isCurrentAnime: release.release.id == widget.animeId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }
} 