import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated orbital logo — golden core with two orbiting rings.
class OrbitalLogo extends StatefulWidget {
  final double size;
  const OrbitalLogo({super.key, this.size = 120});

  @override
  State<OrbitalLogo> createState() => _OrbitalLogoState();
}

class _OrbitalLogoState extends State<OrbitalLogo> with TickerProviderStateMixin {
  late final AnimationController _c1;
  late final AnimationController _c2;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat(reverse: false);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final core = s * 0.42;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer orbit ring
          AnimatedBuilder(
            animation: _c2,
            builder: (_, __) => Transform.rotate(
              angle: -_c2.value * 2 * pi,
              child: _OrbitRing(size: s + 36, color: AppColors.vio.withValues(alpha: 0.3), dashed: true, dotColor: AppColors.vio),
            ),
          ),
          // Inner orbit ring
          AnimatedBuilder(
            animation: _c1,
            builder: (_, __) => Transform.rotate(
              angle: _c1.value * 2 * pi,
              child: _OrbitRing(size: s, color: Colors.white.withValues(alpha: 0.14), dashed: false, dotColor: AppColors.teal),
            ),
          ),
          // Core sun
          Container(
            width: core,
            height: core,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Color(0xFFFFE6A8), Color(0xFFF7B84B), Color(0xFFB9741A)],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.sun.withValues(alpha: 0.6), blurRadius: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRing extends StatelessWidget {
  final double size;
  final Color color;
  final bool dashed;
  final Color dotColor;
  const _OrbitRing({required this.size, required this.color, required this.dashed, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
          ),
          // Dot at top
          Positioned(
            top: -5,
            left: size / 2 - 5,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: [BoxShadow(color: dotColor, blurRadius: 14)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
