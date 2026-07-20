import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/music_studio_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';

  static final pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const MusicStudioScreen()), // Redirect home to Music Studio
  ];
}
