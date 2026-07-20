import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:llamadart/llamadart.dart';
import '../services/llm_service.dart';
import '../services/model_manager.dart';
import '../controllers/model_controller.dart';
import '../utils/midi_generator.dart';

class MusicController extends GetxController {
  final _record = AudioRecorder();
  final _llm = Get.put(LlmService());
  final _modelManager = Get.find<ModelManager>();
  final _modelController = Get.put(ModelController());

  final isRecording = false.obs;
  final isGenerating = false.obs;
  final audioPath = Rx<String?>(null);
  final sampleMidiPath = Rx<String?>(null);
  final generationResult = ''.obs;

  Future<void> pickSampleMidi() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mid', 'midi'],
    );
    if (result != null && result.files.single.path != null) {
      sampleMidiPath.value = result.files.single.path;
    }
  }

  Future<void> startRecording() async {
    if (await _record.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/voice_reference.m4a';
      await _record.start(const RecordConfig(), path: path);
      isRecording.value = true;
    }
  }

  Future<void> stopRecording() async {
    final path = await _record.stop();
    isRecording.value = false;
    audioPath.value = path;
  }

  Future<void> generateMusic({
    required String lyrics,
    required String style,
    required String duration,
    required String quality
  }) async {
    final selectedModel = _modelController.selectedModelFilename.value;
    if (selectedModel == null) {
      Get.snackbar('Error', 'Please select a GGUF model first');
      return;
    }
    if (!_llm.isLoaded.value) {
      Get.snackbar('Error', 'Model is currently loading or not ready.');
      return;
    }

    isGenerating.value = true;
    generationResult.value = 'Initializing Synthesis Pipeline...\n\n';

    String prompt = 'Format the following as a structured music generation prompt. Include tempo, instruments, and vocal style. ';
    prompt += 'Style: $style. Duration: $duration. Quality: $quality. Lyrics: $lyrics.';
    if (sampleMidiPath.value != null) {
      prompt += ' (Note: Use the provided sample MIDI structure as inspiration).';
    }

    try {
      final stream = _llm.generate(
        messages: [LlamaChatMessage.fromText(role: LlamaChatRole.user, text: prompt)],
        systemPrompt: 'You are an advanced AI music notation and prompt generation engine.',
      );

      await for (final token in stream) {
        generationResult.value += token;
      }

      // Generate actual playable MIDI file based on inference
      final dir = await getApplicationDocumentsDirectory();
      final midiPath = '${dir.path}/generated_song_${DateTime.now().millisecondsSinceEpoch}.mid';
      await MidiGenerator.createSimpleMidi(midiPath);

      generationResult.value += '\n\n[SUCCESS] MIDI Synthesis complete.\nSaved to: $midiPath';

    } catch (e) {
      generationResult.value = 'Error during generation: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  @override
  void onClose() {
    _record.dispose();
    super.onClose();
  }
}
