import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'fluid_glow_painter.dart';

class AppleIntelligenceOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onDismiss;

  const AppleIntelligenceOverlay({
    super.key,
    required this.isVisible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Dim
          GestureDetector(
            onTap: onDismiss,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isVisible ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // The Fluid Glow Overlay
          Positioned.fill(
            child: FluidGlowPainter(
              isVisible: true,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
