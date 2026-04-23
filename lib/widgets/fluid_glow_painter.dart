import 'package:flutter/material.dart';
import 'dart:math' as math;

class FluidGlowPainter extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const FluidGlowPainter({
    super.key,
    required this.child,
    this.isVisible = false,
  });

  @override
  State<FluidGlowPainter> createState() => _FluidGlowPainterState();
}

class _FluidGlowPainterState extends State<FluidGlowPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FluidPainter(progress: _controller.value),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _FluidPainter extends CustomPainter {
  final double progress;

  _FluidPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final List<Color> siriColors = [
      const Color(0xFF00D2FF), // Cyan
      const Color(0xFF3A7BD5), // Blue
      const Color(0xFF8E2DE2), // Purple
      const Color(0xFFFF00CC), // Pink
      const Color(0xFFFF9500), // Orange
      const Color(0xFF00D2FF), // Cyan
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    // Multi-layered edge glow with offset rotation
    for (int i = 0; i < 3; i++) {
      final double localProgress = (progress + (i * 0.33)) % 1.0;
      final edgeGradient = SweepGradient(
        colors: siriColors,
        transform: GradientRotation(localProgress * 2 * math.pi * (i.isEven ? 1 : -1)),
      ).createShader(rect);

      paint.shader = edgeGradient;
      paint.strokeWidth = 20.0 + (math.sin(progress * 2 * math.pi) * 10);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(5 + (i * 4).toDouble()), const Radius.circular(45)),
        paint,
      );
    }

    // Bottom primary glow intensity
    final bottomRect = Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2);
    final bottomGradient = LinearGradient(
      colors: [Colors.transparent, const Color(0xFF8E2DE2).withOpacity(0.4), Colors.transparent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bottomRect);

    final bPaint = Paint()
      ..shader = bottomGradient
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawRect(bottomRect, bPaint);
  }

  @override
  bool shouldRepaint(covariant _FluidPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
