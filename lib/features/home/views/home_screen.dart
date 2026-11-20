import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/cosmic_background.dart';
import '../../../ui/motion.dart';
import '../../../ui/stroke_icon.dart';
import '../../predictions/views/planner_tab.dart';
import '../../reports/views/reports_tab.dart';
import 'acharyaji_tab.dart';
import 'home_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    final topInset = MediaQuery.of(context).padding.top;

    // Android back: go to Today first, only then leave the app.
    return Obx(() => PopScope(
          canPop: home.currentNavIndex.value == HomeController.tabToday,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) home.changeNav(HomeController.tabToday);
          },
          child: Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      body: BackdropGroup(
        child: Stack(
          children: [
            const Positioned.fill(child: CosmicBackground()),
            Positioned.fill(
              child: Obx(() => _TabSwitcher(index: home.currentNavIndex.value)),
            ),
            // Scrim behind the status bar so scrolled content doesn't
            // collide with the clock and icons.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset + 28,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0.85), AppColors.bg.withValues(alpha: 0)],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: Obx(() => _TabBar(
                    active: home.currentNavIndex.value,
                    onTap: home.changeNav,
                  )),
            ),
          ],
        ),
      ),
    ),
        ));
  }
}

/// Keeps every tab alive (scroll position, loaded data) and cross-fades +
/// lifts the incoming tab like the prototype's `.view` transition.
class _TabSwitcher extends StatelessWidget {
  final int index;
  const _TabSwitcher({required this.index});

  static const _tabs = [HomeTab(), ReportsTab(), PlannerTab(), AcharyajiTab()];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != index,
              child: TickerMode(
                enabled: i == index,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  curve: kEase,
                  child: AnimatedSlide(
                    offset: i == index ? Offset.zero : const Offset(0, 0.025),
                    duration: const Duration(milliseconds: 450),
                    curve: kEase,
                    child: _tabs[i],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TabDef {
  final String label;
  final String path;
  final String extra;
  const _TabDef(this.label, this.path, [this.extra = '']);
}

/// Floating glass tab bar (prototype `.tabbar`, blur 22 px, sliding pill).
class _TabBar extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const _TabBar({required this.active, required this.onTap});

  static const _tabs = [
    _TabDef('Today', Ic.sunRays, Ic.sunCircle),
    _TabDef('Reports', Ic.doc),
    _TabDef('Planner', Ic.calendar),
    _TabDef('Acharyaji', Ic.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 40, offset: const Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              // A touch more opaque than the prototype's .72 so the icons
              // stay legible over bright cards scrolling underneath.
              color: const Color(0xD9141630),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth / _tabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: kEase,
                    left: w * active + 4,
                    width: w - 8,
                    top: 2,
                    bottom: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.sun.withValues(alpha: 0.14),
                        border: Border.all(color: AppColors.sun.withValues(alpha: 0.32)),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: i == active,
                            label: _tabs[i].label,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: _TabItem(def: _tabs[i], active: i == active),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final _TabDef def;
  final bool active;
  const _TabItem({required this.def, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.sun2 : AppColors.tx2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: active ? 1.08 : 1,
          duration: const Duration(milliseconds: 350),
          curve: kEase,
          child: AnimatedSlide(
            offset: active ? const Offset(0, -0.08) : Offset.zero,
            duration: const Duration(milliseconds: 350),
            curve: kEase,
            child: StrokeIcon(def.path, extra: def.extra, color: color, size: 22, strokeWidth: 1.9),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          child: Text(def.label),
        ),
      ],
    );
  }
}
