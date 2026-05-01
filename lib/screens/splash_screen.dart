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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 4));
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
            Stack(
              alignment: Alignment.center,
              children: [
                // Digital Aura
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonCyan.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).scale(duration: 2.ms * 1000, curve: Curves.easeInOut).fadeIn(),

                // Neural Core
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: AppColors.neonPurple.withOpacity(0.4), blurRadius: 60, spreadRadius: 10)
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppColors.neuralGradient.createShader(bounds),
                    child: const Icon(Icons.psychology_rounded, size: 160, color: Colors.white),
                  ),
                ).animate().scale(duration: 1.ms * 1000, curve: Curves.elasticOut).shimmer(duration: 3.ms * 1000),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              'NEURAL INTERFACE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                color: Colors.white,
                shadows: [Shadow(color: AppColors.neonCyan, blurRadius: 20)]
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 12),
            Text(
              'YEAR 2089 // INITIALIZING UPLINK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.white.withOpacity(0.5),
              ),
            ).animate().fadeIn(delay: 1.ms * 1000),
          ],
        ),
      ),
    );
  }
}
