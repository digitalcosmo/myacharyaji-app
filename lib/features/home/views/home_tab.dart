import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/prediction_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final pred = Get.find<PredictionController>();
    final report = Get.find<ReportController>();
    final now = DateTime.now();
    final dayStr = DateFormat('EEE, d MMMM').format(now);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          // ── Top bar ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dayStr,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.tx3)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${_greet()}, ${report.selectedName.value.isNotEmpty ? report.selectedName.value.split(' ').first : 'there'}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tx),
                        )),
                  ],
                ),
              ),
              _IconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Rashi forecast label ──
          Text(
              'RASHI FORECAST · ${DateFormat('MMMM').format(now).toUpperCase()}',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tx3,
                  letterSpacing: 1.4)),
          const SizedBox(height: 6),
          Text('Pick your moon sign to see this month\'s 5D outlook.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2)),
          const SizedBox(height: 14),

          // ── Rashi scroller ──
          SizedBox(
            height: 96,
            child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 12,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sel = home.selectedRashi.value == i;
                    return GestureDetector(
                      onTap: () {
                        home.selectRashi(i);
                        Get.toNamed('/rashi-prediction', arguments: i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: const Cubic(.22, 1, .36, 1),
                        width: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: sel
                              ? null
                              : AppColors.card,
                          gradient: sel
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.sun.withValues(alpha: 0.25),
                                    AppColors.sun.withValues(alpha: 0.08),
                                  ],
                                )
                              : null,
                          border: Border.all(
                              color: sel
                                  ? AppColors.sun.withValues(alpha: 0.5)
                                  : AppColors.line),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppColors.rashiSymbols[i],
                              style: TextStyle(
                                  fontSize: 26,
                                  color:
                                      sel ? AppColors.sun : AppColors.tx2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppColors.rashiNames[i],
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? AppColors.sun2
                                      : AppColors.tx2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          const SizedBox(height: 18),

          // ── Selected rashi card with 5D bars ──
          Obx(() {
            final sel = home.selectedRashi.value;
            return _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.sun.withValues(alpha: 0.14),
                        ),
                        child: Center(
                          child: Text(AppColors.rashiSymbols[sel],
                              style: const TextStyle(
                                  fontSize: 28, color: AppColors.sun2)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppColors.rashiNames[sel],
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tx)),
                          Text('5D outlook this month',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.tx3)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (pred.isLoading.value)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: AppColors.sun)))
                  else
                    ...pred.dimensions.map((d) => _DimBarRow(
                          label: d['label'],
                          dimKey: d['key'],
                          score: d['score'],
                          color: AppColors.dimensionColor[d['key']] ??
                              AppColors.sun,
                        )),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),

          // ── CTA card ──
          _GlassCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.vio.withValues(alpha: 0.16),
                AppColors.teal.withValues(alpha: 0.06)
              ],
            ),
            borderColor: AppColors.vio.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    'This is general, for every ${AppColors.rashiNames[home.selectedRashi.value]}',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx))),
                const SizedBox(height: 6),
                Text(
                  'Your personal Sentiments, Situations and 5D come from your own birth chart. Your Acharyaji can prepare them for you.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.tx2, height: 1.5),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Get.find<HomeController>().changeNav(3),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: AppColors.sun.withValues(alpha: 0.5)),
                      color: AppColors.sun.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ask your Acharyaji',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sun2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Members section ──
          Obx(() {
            if (report.reportList.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR MEMBERS',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tx3,
                        letterSpacing: 1.4)),
                const SizedBox(height: 12),
                ...report.reportList.map((r) => _MemberTile(member: r)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Glass-morphism card matching prototype's .card class
class _GlassCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? borderColor;
  const _GlassCard({required this.child, this.gradient, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: gradient == null ? AppColors.card : null,
        gradient: gradient,
        border: Border.all(color: borderColor ?? AppColors.line),
      ),
      child: child,
    );
  }
}

/// Dimension bar row matching prototype's .bar-row
class _DimBarRow extends StatelessWidget {
  final String label;
  final String dimKey;
  final int score;
  final Color color;
  const _DimBarRow(
      {required this.label,
      required this.dimKey,
      required this.score,
      required this.color});

  static const _dimIcons = {
    'career': Icons.work_outline,
    'finance': Icons.attach_money,
    'social': Icons.people_outline,
    'health': Icons.favorite_border,
    'love': Icons.volunteer_activism_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Dimension icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(
              _dimIcons[dimKey] ?? Icons.star_outline,
              size: 15,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2)),
          ),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white.withValues(alpha: 0.07),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: score / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text('$score',
                textAlign: TextAlign.right,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tx)),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member['Name'] ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: () {
        final rc = Get.find<ReportController>();
        final idx = rc.reportList.indexOf(member);
        if (idx >= 0) rc.selectMember(idx);
        Get.find<HomeController>().changeNav(2);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.card,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            // Conic gradient avatar like prototype
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const SweepGradient(
                  startAngle: 3.5,
                  colors: [
                    AppColors.sun,
                    AppColors.sun2,
                    AppColors.rose,
                    AppColors.sun,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1205)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tx),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${member['Duration'] ?? ''} months',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.tx3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.tx3, size: 20),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          color: AppColors.card,
        ),
        child: Icon(icon, color: AppColors.tx, size: 20),
      ),
    );
  }
}
