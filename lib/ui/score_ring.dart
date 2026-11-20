import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'motion.dart';
import 'tokens.dart';

/// Radial gauge (prototype `.arc`: stroke-dashoffset over 1.3 s).
class ScoreRing extends StatelessWidget {
  final double value; // 0..100
  final List<Color> colors;
  final double size;
  final double stroke;
  final String? caption;

  const ScoreRing({
    super.key,
    required this.value,
    required this.colors,
    this.size = 112,
    this.stroke = 10,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 100) / 100),
      duration: const Duration(milliseconds: 1300),
      curve: kEase,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, colors, stroke),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(v * 100).round()}',
                    style: T.h2.copyWith(fontSize: size * 0.26, height: 1)),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  Text(caption!, style: T.small.copyWith(fontSize: 11)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final List<Color> colors;
  final double stroke;
  _RingPainter(this.v, this.colors, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(r, 0, math.pi * 2, false, track);
    if (v <= 0) return;
    final arc = Paint()
      ..shader = SweepGradient(
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(r)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.v != v || old.colors != colors;
}
