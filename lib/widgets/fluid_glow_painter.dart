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
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _opacityController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isVisible) _opacityController.forward();
  }

  @override
  void didUpdateWidget(FluidGlowPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseController, _opacityController]),
          builder: (context, child) {
            if (_opacityController.value == 0) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _opacityController.value,
                  child: CustomPaint(
                    painter: _AppleGlowPainter(
                      rotation: _rotationController.value,
                      pulse: _pulseController.value,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AppleGlowPainter extends CustomPainter {
  final double rotation;
  final double pulse;

  _AppleGlowPainter({required this.rotation, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);

    // Apple Intelligence Palette
    final colors = [
      const Color(0xFF4285F4).withOpacity(0.8), // Blue
      const Color(0xFF9B51E0).withOpacity(0.8), // Purple
      const Color(0xFFEB5757).withOpacity(0.8), // Red
      const Color(0xFFF2C94C).withOpacity(0.8), // Yellow
      const Color(0xFF27AE60).withOpacity(0.8), // Green
      const Color(0xFF2D9CDB).withOpacity(0.8), // Light Blue
      const Color(0xFF4285F4).withOpacity(0.8), // Cycle
    ];

    // 1. Layer: Background Bloom
    final bloomPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (rotation * 2 * math.pi) + (i * math.pi / 2);
      final offset = Offset(
        math.cos(angle) * (size.width / 3),
        math.sin(angle) * (size.height / 3),
      );

      bloomPaint.color = colors[i % colors.length].withOpacity(0.15 * (1 + pulse * 0.5));
      canvas.drawCircle(center + offset, 150 + (pulse * 50), bloomPaint);
    }

    // 2. Layer: Edge Rainbow Border
    final double thickness = 12.0 + (pulse * 8.0);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final sweepGradient = SweepGradient(
      colors: colors,
      transform: GradientRotation(rotation * 2 * math.pi),
    );

    borderPaint.shader = sweepGradient.createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(thickness / 2),
      const Radius.circular(50),
    );

    canvas.drawRRect(rrect, borderPaint);

    // 3. Layer: Intense Corner Highlights
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness / 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = 0; i < 4; i++) {
      final highlightGradient = SweepGradient(
        center: i == 0 ? Alignment.topLeft : i == 1 ? Alignment.topRight : i == 2 ? Alignment.bottomRight : Alignment.bottomLeft,
        colors: [Colors.white.withOpacity(0.5), Colors.transparent],
        startAngle: 0,
        endAngle: math.pi / 2,
        transform: GradientRotation(rotation * 4 * math.pi),
      ).createShader(rect);

      highlightPaint.shader = highlightGradient;
      canvas.drawRRect(rrect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AppleGlowPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
}
