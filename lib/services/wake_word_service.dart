import 'package:get/get.dart';
import 'package:porcupine_flutter/porcupine.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';

class WakeWordService extends GetxService {
  PorcupineManager? _porcupineManager;
  final isListening = false.obs;
  final onWakeWordDetected = Rxn<void>();

  // You need an access key from Picovoice Console
  static const _accessKey = "YOUR_ACCESS_KEY_HERE";

  Future<void> init() async {
    if (_accessKey == "YOUR_ACCESS_KEY_HERE") {
      print("WakeWord error: Picovoice Access Key is missing. Please set it in wake_word_service.dart.");
      return;
    }
    try {
      _porcupineManager = await PorcupineManager.fromBuiltInKeywords(
        _accessKey,
        [BuiltInKeyword.COMPUTER],
        _wakeWordCallback
      );
    } on PorcupineException catch (e) {
      print("WakeWord init error: ${e.message}");
    }
  }

  void _wakeWordCallback(int keywordIndex) {
    if (keywordIndex == 0) {
      onWakeWordDetected.trigger(null);
    }
  }

  Future<void> start() async {
    try {
      await _porcupineManager?.start();
      isListening.value = true;
    } catch (e) {
      print("WakeWord start error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _porcupineManager?.stop();
      isListening.value = false;
    } catch (e) {
      print("WakeWord stop error: $e");
    }
  }

  @override
  void onClose() {
    _porcupineManager?.delete();
    super.onClose();
  }
}
