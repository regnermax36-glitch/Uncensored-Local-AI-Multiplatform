class AiModelInfo {
  final String name, filename, downloadUrl, provider, description;
  final double sizeGb;
  final int minRamGb;
  final bool isUncensored;

  const AiModelInfo({
    required this.name,
    required this.filename,
    required this.downloadUrl,
    required this.sizeGb,
    required this.minRamGb,
    required this.provider,
    required this.description,
    this.isUncensored = false,
  });

  factory AiModelInfo.fromJson(Map<String, dynamic> json) => AiModelInfo(
    name: json['name'] ?? '',
    filename: json['filename'] ?? '',
    downloadUrl: json['downloadUrl'] ?? '',
    sizeGb: (json['sizeGb'] ?? 0).toDouble(),
    minRamGb: json['minRamGb'] ?? 4,
    provider: json['provider'] ?? 'Unknown',
    description: json['description'] ?? '',
    isUncensored: json['isUncensored'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'filename': filename,
    'downloadUrl': downloadUrl,
    'sizeGb': sizeGb,
    'minRamGb': minRamGb,
    'provider': provider,
    'description': description,
    'isUncensored': isUncensored,
  };
}
