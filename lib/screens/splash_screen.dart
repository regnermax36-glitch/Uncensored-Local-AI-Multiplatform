import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.purple.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)
                ],
              ),
              child: Image.network(
                'https://www.apple.com/v/apple-intelligence/a/images/overview/hero/apple_intelligence_icon__f9v7p6x8r1yq_large.png',
                width: 150,
                height: 150,
              ),
            ).animate().scale(duration: 1200.ms, curve: Curves.elasticOut).fadeIn(),
            const SizedBox(height: 40),
            Text(
              'Apple Intelligence',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                color: Colors.white,
                shadows: [Shadow(color: Colors.white24, blurRadius: 20)]
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
