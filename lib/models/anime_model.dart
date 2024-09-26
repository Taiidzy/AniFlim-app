class Anime {
  final String id;
  final String name;
  final String img;
  final int release;
  final String release_date;
  final String studio;
  final String description;
  final String status;
  final String genres;

  Anime({
    required this.id,
    required this.name,
    required this.img,
    required this.release,
    required this.release_date,
    required this.studio,
    required this.description,
    required this.status,
    required this.genres,
  });

  // Преобразование JSON в объект Anime
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      name: json['name'],
      img: json['img'],
      release: json['release'],
      release_date: json['release_date'],
      studio: json['studio'],
      description: json['description'],
      status: json['status'],
      genres: json['genres'],
    );
  }
}