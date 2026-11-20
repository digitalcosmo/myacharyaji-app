import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import 'controls.dart';
import 'cosmic_background.dart';
import 'motion.dart';
import 'stroke_icon.dart';
import 'tokens.dart';

/// Pushed screen with the same space background, a round back button and a
/// staggered content entrance.
class SubPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  const SubPage({super.key, required this.title, required this.children, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, MediaQuery.of(context).padding.bottom + 32),
      children: [
        Row(
          children: [
            RoundIconButton(icon: Ic.chevLeft, tooltip: 'Back', onTap: () => Get.back()),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: T.h2)),
          ],
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          FadeSlideIn(delay: Duration(milliseconds: 60 * i), child: children[i]),
        ],
      ],
    );
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BackdropGroup(
        child: Stack(
          children: [
            const Positioned.fill(child: CosmicBackground()),
            Positioned.fill(
              child: onRefresh == null
                  ? list
                  : RefreshIndicator(
                      onRefresh: onRefresh!,
                      color: AppColors.sun,
                      backgroundColor: AppColors.bg2,
                      child: list,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
