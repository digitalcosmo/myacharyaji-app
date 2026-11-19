import 'package:flutter/material.dart';

/// Full-screen dark cosmic background with radial aura blurs.
class CosmicBg extends StatelessWidget {
  final Widget child;
  const CosmicBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.8),
          radius: 1.4,
          colors: [Color(0xFF1A1548), Color(0xFF05060F)],
          stops: [0.0, 0.6],
        ),
      ),
      child: Stack(
        children: [
          // Teal aura bottom right
          Positioned(
            bottom: 80,
            right: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF0F5A63).withValues(alpha: 0.55),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Gold aura mid
          Positioned(
            top: 280,
            left: 120,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF7A4A12).withValues(alpha: 0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
