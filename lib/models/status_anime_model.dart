class AnimeStatusModel {
  final String? animeId;
  final String? episode;
  final String? status;
  
  AnimeStatusModel({
    this.animeId,
    this.episode,
    this.status,

  });

  factory AnimeStatusModel.fromJson(Map<String, dynamic> json) {
    return AnimeStatusModel(
      animeId: json['id'],
      episode: json['episode'],
      status: json['status'],
    );
  }

}
