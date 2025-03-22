class Player {
  final String id;
  final String? name;
  final int ordinal;
  final Opening? opening;
  final Ending? ending;
  final Preview? preview;
  final String hls480;
  final String hls720;
  final String hls1080;
  final int duration;
  final String? rutubeId;
  final String? youtubeId;
  final DateTime updatedAt;
  final int sortOrder;
  final String? nameEnglish;
  final Map<String, dynamic> release;

  Player({
    required this.id,
    this.name,
    required this.ordinal,
    this.opening,
    this.ending,
    this.preview,
    required this.hls480,
    required this.hls720,
    required this.hls1080,
    required this.duration,
    this.rutubeId,
    this.youtubeId,
    required this.updatedAt,
    required this.sortOrder,
    this.nameEnglish,
    required this.release,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      ordinal: json['ordinal'],
      opening: json['opening'] != null ? Opening.fromJson(json['opening']) : null,
      ending: json['ending'] != null ? Ending.fromJson(json['ending']) : null,
      preview: json['preview'] != null ? Preview.fromJson(json['preview']) : null,
      hls480: json['hls_480'],
      hls720: json['hls_720'],
      hls1080: json['hls_1080'],
      duration: json['duration'],
      rutubeId: json['rutube_id'],
      youtubeId: json['youtube_id'],
      updatedAt: DateTime.parse(json['updated_at']),
      sortOrder: json['sort_order'],
      nameEnglish: json['name_english'],
      release: json['release'] ?? {},
    );
  }
}

class Opening {
  final int start;
  final int stop;

  Opening({required this.start, required this.stop});

  factory Opening.fromJson(Map<String, dynamic> json) {
    return Opening(
      start: json['start'],
      stop: json['stop'],
    );
  }
}

class Ending {
  final int start;
  final int stop;

  Ending({required this.start, required this.stop});

  factory Ending.fromJson(Map<String, dynamic> json) {
    return Ending(
      start: json['start'],
      stop: json['stop'],
    );
  }
}

class Preview {
  final String src;
  final String thumbnail;
  final OptimizedPreview? optimized;

  Preview({
    required this.src,
    required this.thumbnail,
    this.optimized,
  });

  factory Preview.fromJson(Map<String, dynamic> json) {
    return Preview(
      src: json['src'],
      thumbnail: json['thumbnail'],
      optimized: json['optimized'] != null ? OptimizedPreview.fromJson(json['optimized']) : null,
    );
  }
}

class OptimizedPreview {
  final String src;
  final String thumbnail;

  OptimizedPreview({
    required this.src,
    required this.thumbnail,
  });

  factory OptimizedPreview.fromJson(Map<String, dynamic> json) {
    return OptimizedPreview(
      src: json['src'],
      thumbnail: json['thumbnail'],
    );
  }
}
