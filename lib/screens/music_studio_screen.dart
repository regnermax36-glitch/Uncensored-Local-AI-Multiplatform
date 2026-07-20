import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../widgets/fluid_glow_painter.dart';
import '../controllers/music_controller.dart';
import 'model_library_screen.dart';

class MusicStudioScreen extends StatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  State<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends State<MusicStudioScreen> {
  final _musicCtrl = Get.put(MusicController());
  final _lyricsController = TextEditingController();
  final _styleController = TextEditingController();

  String _selectedDuration = 'Medium (2:00)';
  String _selectedQuality = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('LLAMusic Studio', style: TextStyle(color: context.text, fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(Icons.dns_rounded, color: context.neonCyan),
            onPressed: () => Get.to(() => const ModelLibraryScreen(embedded: false)),
          )
        ],
      ),
      body: Stack(
        children: [
          FluidGlowPainter(
            isVisible: true,
            child: Container(color: Colors.transparent),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildInputCard('Style / Genre', _styleController, 'e.g., Synthwave, Cyberpunk, Acoustic', Icons.style_rounded, 1),
                  const SizedBox(height: 20),
                  _buildInputCard('Lyrics & Prompt', _lyricsController, 'Enter lyrics or song description...', Icons.lyrics_rounded, 4),
                  const SizedBox(height: 20),
                  _buildOptionsSection(),
                  const SizedBox(height: 30),
                  _buildVoiceRecordSection(),
                  const SizedBox(height: 20),
                  _buildMidiSampleSection(),
                  const SizedBox(height: 40),
                  _buildGenerateButton(),
                  const SizedBox(height: 40),
                  _buildOutputSection(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputCard(String title, TextEditingController ctrl, String hint, IconData icon, int lines) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.neonBlue.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.neonBlue, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: context.text, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: lines,
            style: TextStyle(color: context.text, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.textD),
              border: InputBorder.none,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            'Duration',
            _selectedDuration,
            ['Short (0:30)', 'Medium (2:00)', 'Long (4:00)'],
            (val) => setState(() => _selectedDuration = val!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdown(
            'Quality',
            _selectedQuality,
            ['Draft', 'Standard', 'High (Studio)'],
            (val) => setState(() => _selectedQuality = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.textD, fontSize: 12, fontWeight: FontWeight.bold)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: context.bgSidebar,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.neonCyan),
              style: TextStyle(color: context.text, fontSize: 14),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMidiSampleSection() {
    return Obx(() {
      final samplePath = _musicCtrl.sampleMidiPath.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.neonBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.neonBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.piano_rounded, color: context.neonBlue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MIDI Inspiration (Optional)', style: TextStyle(color: context.text, fontWeight: FontWeight.bold)),
                  Text(samplePath != null ? samplePath.split('/').last : 'Select a .mid file to guide the AI', style: TextStyle(color: context.textM, fontSize: 12)),
                ],
              ),
            ),
            if (samplePath != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.red),
                onPressed: () => _musicCtrl.sampleMidiPath.value = null,
              )
            else
              TextButton(
                onPressed: _musicCtrl.pickSampleMidi,
                child: Text('BROWSE', style: TextStyle(color: context.neonBlue, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      );
    });
  }

  Widget _buildVoiceRecordSection() {
    return Obx(() {
      final isRecording = _musicCtrl.isRecording.value;
      final hasAudio = _musicCtrl.audioPath.value != null;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.neonPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.neonPurple.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? Colors.red.withOpacity(0.2) : context.neonPurple.withOpacity(0.2),
              ),
              child: Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded, color: isRecording ? Colors.red : context.neonPurple, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voice Reference', style: TextStyle(color: context.text, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(hasAudio ? 'Audio captured ready for inference' : (isRecording ? 'Recording...' : 'Tap to record sample'), style: TextStyle(color: context.textM, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isRecording ? _musicCtrl.stopRecording : _musicCtrl.startRecording,
              style: ElevatedButton.styleFrom(backgroundColor: isRecording ? Colors.red : context.neonPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(isRecording ? 'STOP' : 'RECORD', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    });
  }

  Widget _buildGenerateButton() {
    return Obx(() {
      final isGen = _musicCtrl.isGenerating.value;
      return InkWell(
        onTap: isGen ? null : () {
          _musicCtrl.generateMusic(
            lyrics: _lyricsController.text,
            style: _styleController.text,
            duration: _selectedDuration,
            quality: _selectedQuality,
          );
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: context.neonCyan.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Center(
            child: isGen
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('GENERATE MUSIC', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
          ),
        ),
      );
    });
  }

  Widget _buildOutputSection() {
    return Obx(() {
      final result = _musicCtrl.generationResult.value;
      if (result.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.neonCyan.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.neonCyan.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_music_rounded, color: context.neonCyan),
                const SizedBox(width: 10),
                Text('Generation Output', style: TextStyle(color: context.text, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Text(result, style: TextStyle(color: context.textM, fontFamily: 'monospace', height: 1.5)),
          ],
        ),
      );
    });
  }
}
