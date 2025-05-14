class Anime {
  final String id;
  final String name;
  final String img;
  final int release;
  final String releaseDate;
  final String studio;
  final String description;
  final String status;
  final String genres;
  final int publishDayValue;
  final String publishDayDescription;
  final String ageRaiting;

  Anime({
    required this.id,
    required this.name,
    required this.img,
    required this.release,
    required this.releaseDate,
    required this.studio,
    required this.description,
    required this.status,
    required this.genres,
    required this.publishDayValue,
    required this.publishDayDescription,
    required this.ageRaiting,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'].toString(),
      name: json['name'] != null ? json['name']['main'] ?? '' : '',
      img: json['poster'] != null ? json['poster']['src'] ?? '' : '',
      release: json['year'] ?? 0,
      releaseDate: json['year'] != null ? json['year'].toString() : '',
      studio: json['studio'] ?? '',
      description: json['description'] ?? '',
      status: json['is_ongoing'] == true ? "Ongoing" : "Completed",
      genres: json['genres'] != null 
          ? (json['genres'] as List<dynamic>)
              .map((genre) => genre['name'])
              .join(', ')
          : '',
      publishDayValue: json['publish_day'] != null 
          ? int.tryParse(json['publish_day']['value'].toString()) ?? 0 
          : 0,
      publishDayDescription: json['publish_day'] != null 
          ? json['publish_day']['description'] ?? '' 
          : '',
      ageRaiting: json['age_rating'] != null 
          ? json['age_rating']['label'] ?? '' 
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {'main': name},
      'poster': {'src': img},
      'year': release,
      'studio': studio,
      'description': description,
      'is_ongoing': status == "Ongoing",
      'genres': genres.split(', ').map((genre) => {'name': genre}).toList(),
      'publish_day': {
        'value': publishDayValue,
        'description': publishDayDescription,
      },
      'age_rating': {'label': ageRaiting},
    };
  }
}
