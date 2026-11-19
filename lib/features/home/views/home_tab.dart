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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Top bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dayStr, style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '${_greet()}, ${report.selectedName.value.isNotEmpty ? report.selectedName.value.split(' ').first : 'there'}',
                      style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx),
                    )),
                  ],
                ),
              ),
              _iconBtn(Icons.notifications_outlined),
            ],
          ),
          const SizedBox(height: 24),

          // Rashi scroller
          Text('RASHI FORECAST · ${DateFormat('MMMM').format(now).toUpperCase()}',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4),
          ),
          const SizedBox(height: 6),
          Text('Pick your moon sign to see this month\'s 5D outlook.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx2),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: Obx(() => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final sel = home.selectedRashi.value == i;
                return GestureDetector(
                  onTap: () {
                    home.selectRashi(i);
                    Get.toNamed('/rashi-prediction', arguments: i);
                  },
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: sel ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
                      border: Border.all(color: sel ? AppColors.sun : AppColors.line),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppColors.rashiSymbols[i],
                          style: TextStyle(fontSize: 22, color: sel ? AppColors.sun : AppColors.tx2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppColors.rashiNames[i].substring(0, 3),
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: sel ? AppColors.sun : AppColors.tx3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
          const SizedBox(height: 18),

          // Selected rashi card with 5D bars
          Obx(() {
            final sel = home.selectedRashi.value;
            return _CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.sun.withValues(alpha: 0.14),
                        ),
                        child: Center(
                          child: Text(AppColors.rashiSymbols[sel], style: const TextStyle(fontSize: 28, color: AppColors.sun2)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppColors.rashiNames[sel], style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx)),
                          Text('5D outlook this month', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // 5D bars from prediction data
                  if (pred.isLoading.value)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.sun)))
                  else
                    ...pred.dimensions.map((d) => _DimBar(
                      label: d['label'],
                      score: d['score'],
                      color: AppColors.dimensionColor[d['key']] ?? AppColors.sun,
                    )),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),

          // CTA card
          _CosmicCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.vio.withValues(alpha: 0.16), AppColors.teal.withValues(alpha: 0.06)],
            ),
            borderColor: AppColors.vio.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This is general, for every ${AppColors.rashiNames[home.selectedRashi.value]}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.tx),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your personal Sentiments, Situations and 5D come from your own birth chart. Your Acharyaji can prepare them for you.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2, height: 1.5),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => Get.find<HomeController>().changeNav(3),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.sun.withValues(alpha: 0.5)),
                    backgroundColor: AppColors.sun.withValues(alpha: 0.08),
                    foregroundColor: AppColors.sun2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: Text('Ask your Acharyaji', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Members section
          Obx(() {
            if (report.reportList.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR MEMBERS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
                const SizedBox(height: 12),
                ...report.reportList.map((r) => _MemberTile(member: r)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        color: AppColors.card,
      ),
      child: Icon(icon, color: AppColors.tx, size: 20),
    );
  }
}

class _CosmicCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? borderColor;
  const _CosmicCard({required this.child, this.gradient, this.borderColor});

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

class _DimBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _DimBar({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx2))),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.line,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: score / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text('$score%', textAlign: TextAlign.right, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tx)),
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
    return GestureDetector(
      onTap: () {
        final rc = Get.find<ReportController>();
        final idx = rc.reportList.indexOf(member);
        if (idx >= 0) rc.selectMember(idx);
        Get.find<HomeController>().changeNav(2); // go to planner
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
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.vio.withValues(alpha: 0.15),
              ),
              child: Center(child: Text(
                (member['Name'] ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.vio),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member['Name'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tx), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${member['Duration'] ?? ''} months', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
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
