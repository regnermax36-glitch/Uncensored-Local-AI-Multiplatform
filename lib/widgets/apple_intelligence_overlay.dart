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
  late AnimationController _neuralController;

  @override
  void initState() {
    super.initState();
    _neuralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _neuralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.2, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
      child: widget.isVisible
        ? Material(
            key: const ValueKey('neural_overlay_2089'),
            color: Colors.transparent,
            child: Stack(
              children: [
                // Neural Void Background
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              const Color(0xFF00D2FF).withOpacity(0.1),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Holographic UI Elements
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHolographicCore(),
                        const SizedBox(height: 60),
                        _buildTypewriterText('SYSTEM: NEURAL LINK ACTIVE'),
                        const SizedBox(height: 16),
                        _buildSubStatus('SYNAPSE CONNECTED // 2089-WWDC'),
                      ],
                    ),
                  ),
                ),

                // Corner Control
                Positioned(
                  top: 60,
                  right: 30,
                  child: _holographicButton(Icons.close_rounded, widget.onDismiss),
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildHolographicCore() {
    return AnimatedBuilder(
      animation: _neuralController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Outer Rings
            Transform.rotate(
              angle: _neuralController.value * 2 * 3.14159,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00FFF2).withOpacity(0.2), width: 1),
                ),
              ),
            ),
            Transform.rotate(
              angle: -_neuralController.value * 4 * 3.14159,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9B51E0).withOpacity(0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                ),
              ),
            ),
            // Central Neural Core
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF9B51E0)],
                ).createShader(bounds),
                child: const Icon(Icons.psychology_rounded, size: 100, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypewriterText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 4,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildSubStatus(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF00FFF2).withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _holographicButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}
