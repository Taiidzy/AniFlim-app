class Episode {
  final int episode;
  final String id;
  final int ordinal;
  final String? hls480;
  final String? hls720;
  final String? hls1080;
  
  Episode({
    required this.episode,
    required this.id,
    required this.ordinal,
    this.hls480,
    this.hls720,
    this.hls1080,

  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episode: json['ordinal'] as int, // Номер эпизода
      id: json['id'] as String, // UUID эпизода
      ordinal: json['ordinal'] as int,
      hls480: json['hls_480'], // Разрешаем `null`
      hls720: json['hls_720'], // Разрешаем `null`
      hls1080: json['hls_1080'], // Разрешаем `null`
    );
  }
}
