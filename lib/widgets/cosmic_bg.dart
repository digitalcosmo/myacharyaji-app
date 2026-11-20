import 'package:flutter/material.dart';
import '../ui/cosmic_background.dart';

/// Full-screen animated space background for the sign-in screens — the same
/// starfield and auras as the main app, always filling the whole screen.
class CosmicBg extends StatelessWidget {
  final Widget child;
  const CosmicBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: CosmicBackground()),
        Positioned.fill(child: child),
      ],
    );
  }
}
