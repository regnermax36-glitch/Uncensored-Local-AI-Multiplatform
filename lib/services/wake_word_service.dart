import 'dart:async';
import 'package:get/get.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import '../controllers/chat_controller.dart';

class WakeWordService extends GetxService {
  late ManualSttController _sttController;
  final isListening = false.obs;
  final onWakeWordDetected = Rxn<void>();

  Future<void> init() async {
    _sttController = ManualSttController(Get.context!);
    _sttController.listen(
      onListeningTextChanged: (text) {
        final lowerText = text.toLowerCase();
        if (lowerText.contains("computer") || lowerText.contains("hey siri")) {
          onWakeWordDetected.trigger(null);
          // Pause briefly after detection to prevent double triggers
          stop();
          Future.delayed(const Duration(seconds: 2), () => start());
        }
      },
      onListeningStateChanged: (state) {
        if (state == ManualSttState.listening) {
          isListening.value = true;
        } else {
          isListening.value = false;
        }
      },
    );
  }

  Future<void> start() async {
    final chatCtrl = Get.find<ChatController>();
    if (chatCtrl.isListening.value) return;

    try {
      _sttController.startStt();
    } catch (e) {
      print("WakeWord start error: $e");
    }
  }

  Future<void> stop() async {
    try {
      _sttController.stopStt();
    } catch (e) {
      print("WakeWord stop error: $e");
    }
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
