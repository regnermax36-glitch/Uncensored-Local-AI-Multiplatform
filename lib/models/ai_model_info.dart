class AiModelInfo {
  final String id, name, filename, url, label, badge, systemPrompt;
  final double sizeGb;
  final int minRamGb;

  const AiModelInfo({
    required this.id, required this.name, required this.filename,
    required this.url, required this.sizeGb, required this.minRamGb,
    required this.label, required this.badge, required this.systemPrompt,
  });

  factory AiModelInfo.fromJson(Map<String, dynamic> json) => AiModelInfo(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    filename: json['filename'] ?? '',
    url: json['url'] ?? '',
    sizeGb: (json['sizeGb'] ?? 0).toDouble(),
    minRamGb: json['minRamGb'] ?? 4,
    label: json['label'] ?? 'STANDARD',
    badge: json['badge'] ?? '',
    systemPrompt: json['systemPrompt'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'filename': filename, 'url': url,
    'sizeGb': sizeGb, 'minRamGb': minRamGb, 'label': label,
    'badge': badge, 'systemPrompt': systemPrompt,
  };

  bool get isUncensored => label == 'UNCENSORED';
  bool get isStandard => label == 'STANDARD';
  bool get isCustom => label == 'CUSTOM';
}
