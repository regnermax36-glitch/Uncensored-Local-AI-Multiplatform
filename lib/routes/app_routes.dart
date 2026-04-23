import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/model_library_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const models = '/models';
  static const settings = '/settings';

  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: models, page: () => const ModelLibraryScreen(), transition: Transition.cupertino),
    GetPage(name: settings, page: () => const SettingsScreen(), transition: Transition.cupertino),
  ];
}
