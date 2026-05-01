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
  late AnimationController _waveController;
  late AnimationController _opacityController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _opacityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    if (widget.isVisible) _opacityController.forward();
  }

  @override
  void didUpdateWidget(FluidGlowPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible) _opacityController.forward(); else _opacityController.reverse();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _waveController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _waveController, _opacityController]),
          builder: (context, child) {
            if (_opacityController.value == 0) return const SizedBox.shrink();
            return Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _opacityController.value,
                  child: CustomPaint(
                    painter: _Neural2089Painter(
                      rotation: _rotationController.value,
                      wave: _waveController.value,
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

class _Neural2089Painter extends CustomPainter {
  final double rotation;
  final double wave;

  _Neural2089Painter({required this.rotation, required this.wave});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);

    // 2089 Matrix Palette
    final colors = [
      const Color(0xFF00D2FF), // Neon Blue
      const Color(0xFF9B51E0), // Neon Purple
      const Color(0xFF00FFF2), // Neon Cyan
      const Color(0xFFFF00CC), // Neon Pink
      const Color(0xFF00D2FF), // Cycle
    ];

    // 1. Layer: Neural Synapse Bloom
    final bloomPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    for (int i = 0; i < 6; i++) {
      final angle = (rotation * 2 * math.pi) + (i * math.pi / 3);
      final dist = (size.width / 2.5) * (0.8 + wave * 0.4);
      final offset = Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      bloomPaint.color = colors[i % colors.length].withOpacity(0.12 * (0.5 + wave * 0.5));
      canvas.drawCircle(center + offset, 200 + (wave * 100), bloomPaint);
    }

    // 2. Layer: Dynamic Data-Flow Border
    final double thickness = 4.0 + (wave * 12.0);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final sweepGradient = SweepGradient(
      colors: colors,
      transform: GradientRotation(rotation * 4 * math.pi),
    );
    borderPaint.shader = sweepGradient.createShader(rect);

    final rrect = RRect.fromRectAndRadius(rect.deflate(thickness / 2), const Radius.circular(55));
    canvas.drawRRect(rrect, borderPaint);

    // 3. Layer: Kinetic Synapse Lines
    final synapsePaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * wave)
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < 8; i++) {
      final progress = (rotation + (i * 0.125)) % 1.0;
      final x = size.width * progress;
      final yOffset = math.sin(progress * 4 * math.pi) * 50 * wave;
      canvas.drawLine(Offset(x, 0), Offset(x, 40 + yOffset), synapsePaint);
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height - (40 + yOffset)), synapsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _Neural2089Painter oldDelegate) => true;
}
