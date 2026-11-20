import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/planner_report.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tokens.dart';

class ReportBadge {
  final String label;
  final Color color;
  const ReportBadge(this.label, this.color);

  factory ReportBadge.of(PlannerReport r) {
    if (r.isOver) return const ReportBadge('Ended', AppColors.tx3);
    if (r.isUpcoming) return ReportBadge('Starts ${fmtDayShort(r.start)}', AppColors.vio);
    if (!r.isActive) return const ReportBadge('Inactive', AppColors.rose);
    return const ReportBadge('Active', AppColors.teal);
  }
}

const _avatarGradients = [
  [Color(0xFFF7B84B), Color(0xFFB9741A)],
  [Color(0xFF4FD6C4), Color(0xFF1C6E7A)],
  [Color(0xFF9D8DFF), Color(0xFF4B3BB8)],
  [Color(0xFFFF8A7A), Color(0xFFA84035)],
  [Color(0xFF7EE0A8), Color(0xFF2E8A5B)],
];

class ReportAvatar extends StatelessWidget {
  final PlannerReport report;
  final double size;
  const ReportAvatar(this.report, {super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final seed = report.name.codeUnits.fold<int>(0, (a, b) => a + b);
    final g = _avatarGradients[seed % _avatarGradients.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.31),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft highlight (prototype .art::after)
          Positioned(
            top: -size * 0.25,
            right: -size * 0.25,
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          Text(report.initials,
              style: T.h3.copyWith(fontSize: size * 0.34, color: const Color(0xFF14102A))),
        ],
      ),
    );
  }
}

/// A report mapped to the client's number: who it's for, its window, and
/// how far through it we are.
class ReportTile extends StatelessWidget {
  final PlannerReport report;
  final bool selected;
  final VoidCallback? onTap;
  final bool showProgress;

  const ReportTile({
    super.key,
    required this.report,
    this.selected = false,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final b = ReportBadge.of(report);
    final live = report.coversToday;
    return Pressable(
      onTap: onTap,
      child: Glass(
        padding: const EdgeInsets.all(16),
        borderColor: selected ? AppColors.sun.withValues(alpha: 0.55) : null,
        color: selected ? AppColors.sun.withValues(alpha: 0.08) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ReportAvatar(report),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Tag(b.label, b.color),
                          const SizedBox(width: 8),
                          Text('${report.months}-month planner', style: T.small),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(report.name,
                          style: T.h3.copyWith(fontSize: 16.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${fmtMonShortYear(report.start)} – ${fmtMonShortYear(report.end)}',
                          style: T.small),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: selected
                      ? Container(
                          key: const ValueKey('sel'),
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const StrokeIcon(Ic.check, color: Color(0xFF1A1205), size: 16, strokeWidth: 2.6),
                        )
                      : const StrokeIcon(Ic.chevRight, key: ValueKey('chev'), color: AppColors.tx3, size: 18),
                ),
              ],
            ),
            if (showProgress && live) ...[
              const SizedBox(height: 14),
              AnimatedBar(value: report.progress * 100, colors: const [AppColors.sun2, AppColors.sun], height: 6),
              const SizedBox(height: 6),
              Text(
                '${(report.progress * 100).round()}% through · ends ${fmtDayShort(report.end)}',
                style: T.small.copyWith(fontSize: 11.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text.toUpperCase(),
          style: T.cap.copyWith(fontSize: 10, color: color, letterSpacing: 1)),
    );
  }
}
