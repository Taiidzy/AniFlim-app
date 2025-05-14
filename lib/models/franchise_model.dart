import 'package:AniFlim/models/anime_model.dart';

class Franchise {
  final String id;
  final String name;
  final String nameEnglish;
  final String? imagePreview;
  final String? imageThumbnail;
  final int lastYear;
  final int firstYear;
  final int totalEpisodes;
  final int totalReleases;
  final String totalDuration;
  final List<FranchiseRelease> franchiseReleases;

  Franchise({
    required this.id,
    required this.name,
    required this.nameEnglish,
    this.imagePreview,
    this.imageThumbnail,
    required this.lastYear,
    required this.firstYear,
    required this.totalEpisodes,
    required this.totalReleases,
    required this.totalDuration,
    required this.franchiseReleases,
  });

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEnglish: json['name_english'] as String,
      imagePreview: json['image']?['preview'] as String?,
      imageThumbnail: json['image']?['thumbnail'] as String?,
      lastYear: json['last_year'] as int,
      firstYear: json['first_year'] as int,
      totalEpisodes: json['total_episodes'] as int,
      totalReleases: json['total_releases'] as int,
      totalDuration: json['total_duration'] as String,
      franchiseReleases: (json['franchise_releases'] as List)
          .map((release) => FranchiseRelease.fromJson(release))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_english': nameEnglish,
      'image': {
        'preview': imagePreview,
        'thumbnail': imageThumbnail,
      },
      'last_year': lastYear,
      'first_year': firstYear,
      'total_episodes': totalEpisodes,
      'total_releases': totalReleases,
      'total_duration': totalDuration,
      'franchise_releases': franchiseReleases.map((release) => release.toJson()).toList(),
    };
  }
}

class FranchiseRelease {
  final String id;
  final int sortOrder;
  final int releaseId;
  final String franchiseId;
  final Anime release;

  FranchiseRelease({
    required this.id,
    required this.sortOrder,
    required this.releaseId,
    required this.franchiseId,
    required this.release,
  });

  factory FranchiseRelease.fromJson(Map<String, dynamic> json) {
    return FranchiseRelease(
      id: json['id'] as String,
      sortOrder: json['sort_order'] as int,
      releaseId: json['release_id'] as int,
      franchiseId: json['franchise_id'] as String,
      release: Anime.fromJson(json['release']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sort_order': sortOrder,
      'release_id': releaseId,
      'franchise_id': franchiseId,
      'release': release.toJson(),
    };
  }
} 