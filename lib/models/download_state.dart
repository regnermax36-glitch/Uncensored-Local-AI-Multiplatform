class DownloadState {
  final String filename;
  final double totalBytes;
  double receivedBytes = 0;

  DownloadState({
    required this.filename,
    required this.totalBytes,
  });

  double get progress => totalBytes > 0 ? (receivedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

  String get receivedMb => (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
  String get totalMb => (totalBytes / (1024 * 1024)).toStringAsFixed(1);
}
