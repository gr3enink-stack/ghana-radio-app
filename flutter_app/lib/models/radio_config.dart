class RadioConfig {
  final String stationName;
  final String streamUrl;
  final String? albumArtUrl;
  final String? description;

  // DEFAULT VALUES - hardcoded fallbacks for guaranteed uptime
  static const String defaultStreamUrl = 'http://link.zeno.fm:80/42t1rk4rkkhvv';
  static const String defaultAlbumArtUrl = 'https://vasfm-online.vercel.app/logo.png';
  static const String defaultStationName = 'VAS FM Online';
  static const String defaultDescription = 'Your favorite internet radio station';

  RadioConfig({
    required this.stationName,
    required this.streamUrl,
    this.albumArtUrl,
    this.description,
  });

  // Create default config (used when backend fails)
  factory RadioConfig.defaultConfig() {
    return RadioConfig(
      stationName: defaultStationName,
      streamUrl: defaultStreamUrl,
      albumArtUrl: defaultAlbumArtUrl,
      description: defaultDescription,
    );
  }

  factory RadioConfig.fromJson(Map<String, dynamic> json) {
    return RadioConfig(
      stationName: json['stationName'] ?? defaultStationName,
      streamUrl: json['streamUrl'] ?? defaultStreamUrl,
      albumArtUrl: json['albumArtUrl'] ?? defaultAlbumArtUrl,
      description: json['description'] ?? defaultDescription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'streamUrl': streamUrl,
      'albumArtUrl': albumArtUrl,
      'description': description,
    };
  }
}
