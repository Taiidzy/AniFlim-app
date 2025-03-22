class AnimeDetail {
  final String id;
  final String name;
  final String img;
  final int release;
  final String releaseDate;
  final String voiceover;
  final String studio;
  final String description;
  final String status;
  final String genres;
  final String ageRaiting;

  AnimeDetail({
    required this.id,
    required this.name,
    required this.img,
    required this.release,
    required this.releaseDate,
    required this.voiceover,
    required this.studio,
    required this.description,
    required this.status,
    required this.genres,
    required this.ageRaiting,
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    return AnimeDetail(
      id: json['id'].toString(),
      name: json['name']['main'] ?? '',
      img: json['poster']['src'] ?? '',
      release: json['year'] ?? 0,
      releaseDate: json['year'].toString(),
      voiceover: (json['members'] as List<dynamic>)
        .map((actor) => actor['nickname'])
        .join(', '),
      studio: json['studio'] ?? '',
      description: json['description'] ?? '',
      status: json['is_ongoing'] == true ? "Ongoing" : "Completed",
      genres: (json['genres'] as List<dynamic>)
          .map((genre) => genre['name'])
          .join(', '),
      ageRaiting: json['age_rating']['label'] ?? '',
    );
  }
}