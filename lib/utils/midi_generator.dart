import 'dart:io';

class MidiGenerator {
  static Future<String> createSimpleMidi(String path) async {
    // Standard MIDI Header: MThd, Length(6), Format(0), Tracks(1), TimeDivision(480)
    final header = [
      0x4D, 0x54, 0x68, 0x64, // MThd
      0x00, 0x00, 0x00, 0x06, // Header length (always 6)
      0x00, 0x00,             // Format 0
      0x00, 0x01,             // 1 Track
      0x01, 0xE0              // 480 ticks per quarter note
    ];

    // Standard MIDI Track: C-Major Arpeggio (C4, E4, G4, C5)
    final trackData = [
      0x00, 0x90, 0x3C, 0x64, // 0, Note On C4 (60)
      0x83, 0x60, 0x80, 0x3C, 0x00, // 480, Note Off C4

      0x00, 0x90, 0x40, 0x64, // 0, Note On E4 (64)
      0x83, 0x60, 0x80, 0x40, 0x00, // 480, Note Off E4

      0x00, 0x90, 0x43, 0x64, // 0, Note On G4 (67)
      0x83, 0x60, 0x80, 0x43, 0x00, // 480, Note Off G4

      0x00, 0x90, 0x48, 0x64, // 0, Note On C5 (72)
      0x87, 0x40, 0x80, 0x48, 0x00, // 960, Note Off C5 (hold longer)

      0x00, 0xFF, 0x2F, 0x00  // 0, End of Track
    ];

    final trackHeader = [
      0x4D, 0x54, 0x72, 0x6B, // MTrk
      (trackData.length >> 24) & 0xFF,
      (trackData.length >> 16) & 0xFF,
      (trackData.length >> 8) & 0xFF,
      trackData.length & 0xFF
    ];

    final bytes = <int>[...header, ...trackHeader, ...trackData];
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
