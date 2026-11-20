import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Deep-space gradient, two drifting auras and a live twinkling starfield
/// (prototype `#sky` canvas + `.aura`).
class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with TickerProviderStateMixin {
  late final AnimationController _stars =
      AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
  late final AnimationController _aura =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
  late final List<_Star> _list;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _list = List.generate(
      110,
      (_) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        r: 0.4 + rng.nextDouble() * 1.3,
        speed: 0.001 + rng.nextDouble() * 0.004,
        phase: rng.nextDouble() * math.pi * 2,
        base: 0.25 + rng.nextDouble() * 0.75,
      ),
    );
  }

  @override
  void dispose() {
    _stars.dispose();
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B0D24), Color(0xFF080A1A)],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _aura,
          builder: (_, __) {
            final t = Curves.easeInOut.transform(_aura.value);
            return Stack(children: [
              _aurb(left: -90 + 40 * t, top: -60 + 60 * t, size: 340, color: const Color(0xFF3B2C8F), a: 0.55),
              _aurb(right: -120 - 30 * t, bottom: 120 + 50 * t, size: 300, color: const Color(0xFF0F5A63), a: 0.5),
              _aurb(left: 80 + 30 * t, top: 300 - 30 * t, size: 220, color: const Color(0xFF7A4A12), a: 0.22),
            ]);
          },
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _StarfieldPainter(_list, _stars),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }

  Widget _aurb({double? left, double? top, double? right, double? bottom, required double size, required Color color, required double a}) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color.withValues(alpha: a), color.withValues(alpha: 0)]),
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, r, speed, phase, base;
  const _Star({required this.x, required this.y, required this.r, required this.speed, required this.phase, required this.base});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> t;
  _StarfieldPainter(this.stars, this.t) : super(repaint: t);

  final Paint _p = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    for (final s in stars) {
      final x = (s.x + s.speed * v * 60) % 1.0;
      final tw = 0.55 + 0.45 * math.sin(v * math.pi * 2 * 6 + s.phase);
      _p.color = Colors.white.withValues(alpha: (s.base * tw).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x * size.width, s.y * size.height), s.r, _p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => false;
}
