import 'package:get/get.dart';
import '../services/llm_service.dart';
import '../services/model_manager.dart';
import '../services/chat_storage_service.dart';
import '../services/local_api_server_service.dart';
import '../services/wake_word_service.dart';
import '../controllers/chat_controller.dart';
import '../controllers/model_controller.dart';
import '../controllers/system_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LlmService(), fenix: true);
    Get.lazyPut(() => ModelManager(), fenix: true);
    // ChatStorageService is now initialized in main() via putAsync
    Get.lazyPut(() => LocalApiServerService(), fenix: true);
    Get.lazyPut(() => WakeWordService(), fenix: true);

    Get.lazyPut(() => SystemController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => ModelController(), fenix: true);
  }
}
