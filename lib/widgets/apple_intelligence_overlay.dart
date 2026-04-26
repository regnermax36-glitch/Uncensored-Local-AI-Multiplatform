import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'fluid_glow_painter.dart';

class AppleIntelligenceOverlay extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onDismiss;

  const AppleIntelligenceOverlay({
    super.key,
    required this.isVisible,
    required this.onDismiss,
  });

  @override
  State<AppleIntelligenceOverlay> createState() => _AppleIntelligenceOverlayState();
}

class _AppleIntelligenceOverlayState extends State<AppleIntelligenceOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.1, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      child: widget.isVisible
        ? Material(
            key: const ValueKey('apple_overlay'),
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background Glassmorphism
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic Logo with breathing
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            final scale = 1.0 + (_breathingController.value * 0.05);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9B51E0).withOpacity(0.3 * _breathingController.value),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    )
                                  ],
                                ),
                                child: Image.network(
                                  'https://www.apple.com/v/apple-intelligence/a/images/overview/hero/apple_intelligence_icon__f9v7p6x8r1yq_large.png',
                                  width: 130,
                                  height: 130,
                                  errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome_rounded, size: 100, color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'How can I help?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            'Siri is listening...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Corner Dismiss Button
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    ),
                    onPressed: widget.onDismiss,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}
