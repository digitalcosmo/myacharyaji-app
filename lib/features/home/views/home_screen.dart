import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../../controllers/home_controller.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../controllers/info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_tab.dart';
import '../../reports/views/reports_tab.dart';
import '../../predictions/views/planner_tab.dart';
import '../../home/views/acharyaji_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final ic = Get.find<InfoController>();
    if (ic.consultantName.value.isEmpty) {
      ic.loadConsultantDetails();
      ic.loadFAQs();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Cosmic background auras
          const _CosmicBackground(),

          // Main content
          Obx(() => IndexedStack(
            index: home.currentNavIndex.value,
            children: const [
              HomeTab(),
              ReportsTab(),
              PlannerTab(),
              AcharyajiTab(),
            ],
          )),

          // Floating tab bar
          Positioned(
            left: 14,
            right: 14,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: Obx(() => _FloatingTabBar(
              activeIndex: home.currentNavIndex.value,
              onTap: (i) => home.changeNav(i),
            )),
          ),
        ],
      ),
    );
  }
}

/// Floating glass-morphism tab bar matching the HTML prototype
class _FloatingTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  const _FloatingTabBar({required this.activeIndex, required this.onTap});

  static const _tabs = [
    _TabDef('Today', 'M12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M4.9 19.1l1.8-1.8M17.3 6.7l1.8-1.8', true),
    _TabDef('Reports', 'M6 3h9l4 4v14H6zM14 3v5h5M9 13h7M9 17h5', false),
    _TabDef('Planner', 'M3 5h18v16H3zM3 10h18M8 3v4M16 3v4', false),
    _TabDef('Acharyaji', 'M12 8a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21c1.2-4 4.6-6 8-6s6.8 2 8 6', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: const Color(0xB8141630), // rgba(20,22,48,.72)
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Animated pill indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(.22, 1, .36, 1),
              top: 8,
              bottom: 8,
              left: 6 + activeIndex * (1 / 4) * (MediaQuery.of(context).size.width - 28 - 12),
              width: (MediaQuery.of(context).size.width - 28 - 12) / 4 - 12,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.sun.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.sun.withValues(alpha: 0.25)),
                ),
              ),
            ),
            // Tab buttons
            Row(
              children: List.generate(4, (i) {
                final tab = _tabs[i];
                final active = i == activeIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: const Cubic(.22, 1, .36, 1),
                          transform: active
                              ? (Matrix4.identity()..translate(0.0, -2.0)..scale(1.08))
                              : Matrix4.identity(),
                          child: _SvgIcon(
                            path: tab.path,
                            hasCircle: tab.hasCircle,
                            color: active ? AppColors.sun2 : AppColors.tx3,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: active ? AppColors.sun2 : AppColors.tx3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabDef {
  final String label;
  final String path;
  final bool hasCircle; // For the sun icon on Home tab
  const _TabDef(this.label, this.path, this.hasCircle);
}

/// Custom SVG-like icon painter for tab bar icons
class _SvgIcon extends StatelessWidget {
  final String path;
  final bool hasCircle;
  final Color color;
  final double size;
  const _SvgIcon({required this.path, this.hasCircle = false, required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _IconPainter(path: path, hasCircle: hasCircle, color: color),
    );
  }
}

class _IconPainter extends CustomPainter {
  final String path;
  final bool hasCircle;
  final Color color;
  _IconPainter({required this.path, required this.hasCircle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);

    // Parse simple SVG path commands
    final parts = path.split(RegExp(r'(?=[MmLlHhVvCcSsQqAaZz])'));
    final p = Path();
    double cx = 0, cy = 0;

    for (final part in parts) {
      if (part.isEmpty) continue;
      final cmd = part[0];
      final nums = RegExp(r'-?[\d.]+').allMatches(part.substring(1)).map((m) => double.parse(m.group(0)!)).toList();

      switch (cmd) {
        case 'M':
          if (nums.length >= 2) { p.moveTo(nums[0], nums[1]); cx = nums[0]; cy = nums[1]; }
          // Handle implicit lineTo after M
          for (int i = 2; i < nums.length - 1; i += 2) {
            p.lineTo(nums[i], nums[i + 1]); cx = nums[i]; cy = nums[i + 1];
          }
          break;
        case 'L':
          for (int i = 0; i < nums.length - 1; i += 2) {
            p.lineTo(nums[i], nums[i + 1]); cx = nums[i]; cy = nums[i + 1];
          }
          break;
        case 'H':
          for (final n in nums) { p.lineTo(n, cy); cx = n; }
          break;
        case 'V':
          for (final n in nums) { p.lineTo(cx, n); cy = n; }
          break;
        case 'C':
          for (int i = 0; i < nums.length - 5; i += 6) {
            p.cubicTo(nums[i], nums[i + 1], nums[i + 2], nums[i + 3], nums[i + 4], nums[i + 5]);
            cx = nums[i + 4]; cy = nums[i + 5];
          }
          break;
        case 'A':
          // Simplified arc: draw a small arc via cubicTo approximation
          for (int i = 0; i < nums.length - 6; i += 7) {
            final ex = nums[i + 5], ey = nums[i + 6];
            p.quadraticBezierTo((cx + ex) / 2 + nums[i] * 0.4, (cy + ey) / 2 - nums[i + 1] * 0.4, ex, ey);
            cx = ex; cy = ey;
          }
          break;
        case 'z':
        case 'Z':
          p.close();
          break;
      }
    }

    // Draw circle if needed (sun icon)
    if (hasCircle) {
      canvas.drawCircle(const Offset(12, 12), 4, paint);
    }

    canvas.drawPath(p, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) => old.color != color;
}

/// Cosmic background with animated starfield + gradient auras
class _CosmicBackground extends StatefulWidget {
  const _CosmicBackground();

  @override
  State<_CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<_CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    // Generate 80 random stars
    final rng = math.Random(42);
    _stars = List.generate(80, (_) => _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      r: 0.5 + rng.nextDouble() * 1.5,
      speed: 0.002 + rng.nextDouble() * 0.006,
      opacity: 0.3 + rng.nextDouble() * 0.7,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6, -0.8),
              radius: 1.2,
              colors: [Color(0xFF1A1548), Color(0x00050610)],
            ),
          ),
        ),
        // Animated starfield
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_stars, _ctrl.value),
              size: Size.infinite,
            ),
          ),
        ),
        // Teal nebula
        Positioned(
          right: -120,
          bottom: 80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0F5A63).withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Gold aura
        Positioned(
          left: 120,
          top: 280,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7A4A12).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Star {
  final double x, y, r, speed, opacity;
  const _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.opacity,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _StarfieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final dx = (s.x + s.speed * t * 60) % 1.0;
      // Gentle twinkle
      final twinkle = 0.5 + 0.5 * math.sin(t * math.pi * 2 * 3 + s.x * 100);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity * twinkle * 0.8);
      canvas.drawCircle(
        Offset(dx * size.width, s.y * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => true;
}
