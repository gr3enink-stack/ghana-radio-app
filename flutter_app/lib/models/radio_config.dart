class RadioConfig {
  final String stationName;
  final String streamUrl;
  final String? albumArtUrl;
  final String? description;

  RadioConfig({
    required this.stationName,
    required this.streamUrl,
    this.albumArtUrl,
    this.description,
  });

  factory RadioConfig.fromJson(Map<String, dynamic> json) {
    return RadioConfig(
      stationName: json['stationName'] ?? 'Unknown Station',
      streamUrl: json['streamUrl'] ?? '',
      albumArtUrl: json['albumArtUrl'],
      description: json['description'],
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
