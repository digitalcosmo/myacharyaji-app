import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Draws concentric orbital rings with small planet dots.
class OrbitalDecoration extends StatelessWidget {
  final double size;
  final int rings;
  final Color? color;

  const OrbitalDecoration({super.key, this.size = 200, this.rings = 3, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.orbitLine;
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _OrbitalPainter(rings: rings, color: c)),
    );
  }
}

class _OrbitalPainter extends CustomPainter {
  final int rings;
  final Color color;
  _OrbitalPainter({required this.rings, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = color;
    final dotPaint = Paint()..style = PaintingStyle.fill..color = AppColors.solarGold.withOpacity(0.6);

    for (int i = 1; i <= rings; i++) {
      final r = maxR * i / rings;
      canvas.drawCircle(center, r, paint);
      final angle = i * 1.3;
      final dx = center.dx + r * math.cos(angle);
      final dy = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
