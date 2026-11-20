import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../core/theme/app_colors.dart';
import 'motion.dart';

/// Scrollable tab body: safe-area padding, room for the floating tab bar,
/// pull-to-refresh, and a staggered entrance that replays on every visit.
class TabPage extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final double gap;

  const TabPage({super.key, required this.children, this.onRefresh, this.gap = 16});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final top = MediaQuery.of(context).padding.top + 18;
    final bottom = MediaQuery.of(context).padding.bottom + 110;

    final list = Obx(() {
      final v = home.visit.value;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
        children: [
          KeyedSubtree(
            key: ValueKey(v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: gap),
                  FadeSlideIn(delay: Duration(milliseconds: 70 * i), child: children[i]),
                ],
              ],
            ),
          ),
        ],
      );
    });

    if (onRefresh == null) return list;
    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: AppColors.sun,
      backgroundColor: AppColors.bg2,
      edgeOffset: top - 10,
      child: list,
    );
  }
}
