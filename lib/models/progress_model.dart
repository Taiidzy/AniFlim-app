class ProgressModel {
  final String? animeId;
  final String episode;
  final int? currenttime;
  
  ProgressModel({
    this.animeId,
    required this.episode,
    this.currenttime,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      animeId: json['animeId']?.toString(),  // или используйте нужный ключ
      episode: json['episode']?.toString() ?? '',
      currenttime: json['currenttime'] is int ? json['currenttime'] : int.tryParse(json['currenttime'].toString()),
    );
  }
}
