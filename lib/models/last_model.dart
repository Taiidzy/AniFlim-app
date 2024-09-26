class Last {
  final int animeId;
  final String name;
  final String moment;
  final String time;
  final String episode;

  Last({
    required this.animeId,
    required this.name,
    required this.moment,
    required this.episode,
    required this.time,
  });

  factory Last.fromJson(Map<String, dynamic> json) {
    return Last(
      animeId: int.parse(json['animeId']),  // Преобразование строки в число
      name: json['name'],
      moment: json['moment'],
      time: (json['progress'] as List).isNotEmpty ? json['progress'][0].toString() : '0',  // Получение первого элемента из списка 'progress'
      episode: json['episode'],
    );
  }
}
