import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/chat_model.dart';
import 'models/message_model.dart';
import 'theme/app_theme.dart';
import 'bindings/app_bindings.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'services/chat_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Storage
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Register Adapters
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(MessageRoleAdapter());

  // Open Boxes
  await Hive.openBox<ChatModel>('chats');
  await Hive.openBox('settings');
  await Hive.openBox('models_meta');

  // Initialize and Await Services that are required immediately
  await Get.putAsync(() => ChatStorageService().init());

  // Controllers
  final themeCtrl = Get.put(ThemeController());

  runApp(AppleIntelligenceApp(themeCtrl: themeCtrl));
}

class AppleIntelligenceApp extends StatelessWidget {
  final ThemeController themeCtrl;
  const AppleIntelligenceApp({super.key, required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Apple Intelligence',
      debugShowCheckedModeBanner: false,
      themeMode: themeCtrl.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: AppBindings(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
