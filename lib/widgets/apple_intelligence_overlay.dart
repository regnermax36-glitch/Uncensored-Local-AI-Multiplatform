import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';

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
  late AnimationController _siriController;

  @override
  void initState() {
    super.initState();
    _siriController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _siriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCirc,
      switchOutCurve: Curves.easeInCirc,
      child: widget.isVisible
        ? Material(
            key: const ValueKey('siri_ai_overlay'),
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-screen edge glow
                  AnimatedBuilder(
                    animation: _siriController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _SiriEdgeGlowPainter(_siriController.value),
                        size: Size.infinite,
                      );
                    }
                  ),

                  // Bottom Orb
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _siriController,
                        builder: (context, child) {
                          return _buildSiriOrb();
                        },
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 60,
                    right: 30,
                    child: _holographicButton(Icons.close_rounded, widget.onDismiss),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildSiriOrb() {
    final t = _siriController.value;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2FF).withOpacity(0.4),
            blurRadius: 50,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFFFF00CC).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                colors: const [
                  Color(0xFF00D2FF), // Neon Blue
                  Color(0xFFFF00CC), // Neon Pink
                  Color(0xFF9B51E0), // Neon Purple
                  Color(0xFF00FFF2), // Neon Cyan
                  Color(0xFF00D2FF), // Loop back
                ],
                transform: GradientRotation(t * 2 * 3.14159),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black45, // Inner core
              ),
              child: const Icon(Icons.mic_none_rounded, color: Colors.white, size: 40),
            ),
          ),
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

class _SiriEdgeGlowPainter extends CustomPainter {
  final double animationValue;

  _SiriEdgeGlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(40));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    paint.shader = SweepGradient(
      center: Alignment.center,
      colors: const [
        Color(0xFF00D2FF), // Blue
        Color(0xFFFF00CC), // Pink
        Color(0xFF9B51E0), // Purple
        Color(0xFF00FFF2), // Cyan
        Color(0xFF00D2FF), // Blue
      ],
      transform: GradientRotation(animationValue * 2 * 3.14159),
    ).createShader(rect);

    canvas.drawRRect(rrect, paint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    innerPaint.shader = paint.shader;
    canvas.drawRRect(rrect, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _SiriEdgeGlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
