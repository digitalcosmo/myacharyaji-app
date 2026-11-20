import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = Get.find<ReportController>();

    return SafeArea(
      child: Obx(() {
        if (rc.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.sun));
        }
        if (rc.reportList.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text('My Reports',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tx)),
                ),
                Text('${rc.reportList.length} reports',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.tx3)),
              ],
            ),
            const SizedBox(height: 20),

            // Member chip selector
            if (rc.reportList.length > 1) ...[
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rc.reportList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final m = rc.reportList[i];
                    final sel = rc.selectedIndex.value == i;
                    return GestureDetector(
                      onTap: () => rc.selectMember(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: const Cubic(.22, 1, .36, 1),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: sel ? AppColors.tx : AppColors.card,
                          border: Border.all(
                              color: sel ? AppColors.tx : AppColors.line),
                        ),
                        child: Center(
                          child: Text(
                            m['Name'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel
                                  ? const Color(0xFF0B0D1F)
                                  : AppColors.tx2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── NEW banner card ──
            _NewBannerCard(),
            const SizedBox(height: 14),

            // Report cards
            ..._reportTypes.map((rt) => _ReportCard(rt: rt)),
          ],
        );
      }),
    );
  }
}

// ── NEW Banner Card (gradient highlight for latest report) ──
class _NewBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x38F7B84B), // rgba(247,184,75,.22)
            Color(0x1F9D8DFF), // rgba(157,141,255,.12)
          ],
        ),
        border: Border.all(
          color: const Color(0x59F7B84B), // rgba(247,184,75,.35)
        ),
      ),
      child: Row(
        children: [
          Text('NEW',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sun2)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CK Trajectory is ready',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx)),
                const SizedBox(height: 2),
                Text('Delivered by your Acharyaji on 02 Nov',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: AppColors.tx3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _reportTypes = [
  {
    'key': 'blueprint',
    'title': 'CK Blueprint',
    'sub': 'Your kundli, GRAH power & flavour',
    'gradient': [const Color(0xFFF7B84B), const Color(0xFFB9741A)],
    'tag': 'Who you are',
    'date': '12 Oct',
  },
  {
    'key': 'trajectory',
    'title': 'CK Trajectory',
    'sub': 'GRAH Vibes & Intensity over 12 months',
    'gradient': [const Color(0xFF4FD6C4), const Color(0xFF1C6E7A)],
    'tag': "What's coming",
    'date': '02 Nov',
  },
  {
    'key': 'vibes',
    'title': 'CK Vibes',
    'sub': 'Monthly emotional & social weather',
    'gradient': [const Color(0xFFFF8A7A), const Color(0xFFA84035)],
    'tag': 'Vibes',
    'date': '15 Oct',
  },
  {
    'key': 'intensity',
    'title': 'CK Intensity',
    'sub': 'Peak & low energy windows',
    'gradient': [const Color(0xFF9D8DFF), const Color(0xFF4B3BB8)],
    'tag': 'Intensity',
    'date': '15 Oct',
  },
  {
    'key': 'planner',
    'title': 'CK Planner',
    'sub': 'Daily Sentiments & Situations; Plus & Max add 5D',
    'gradient': [const Color(0xFF9D8DFF), const Color(0xFF4B3BB8)],
    'tag': 'Planner',
    'date': '01 Nov',
  },
];

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> rt;
  const _ReportCard({required this.rt});

  @override
  Widget build(BuildContext context) {
    final key = rt['key'] as String;
    final colors = rt['gradient'] as List<Color>;
    final tag = rt['tag'] as String;
    final date = rt['date'] as String;

    return GestureDetector(
      onTap: () => Get.toNamed('/report-reader', arguments: {'type': key}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.card,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            // Gradient art thumbnail with highlight overlay
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Radial highlight (matches prototype .art::after)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.4, -0.4),
                            radius: 0.9,
                            colors: [
                              Colors.white.withValues(alpha: 0.45),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rt['title'] as String,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tx)),
                  const SizedBox(height: 3),
                  Text(rt['sub'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.tx3)),
                  const SizedBox(height: 8),
                  // Tag + date row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colors[0].withValues(alpha: 0.13),
                        ),
                        child: Text(tag.toUpperCase(),
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: colors[0])),
                      ),
                      const SizedBox(width: 8),
                      Text(date,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.tx3)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.tx3.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Text('My Reports',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.tx)),
        const SizedBox(height: 40),

        // Empty art
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.card2,
                    border: Border.all(color: AppColors.line),
                  ),
                ),
                ...List.generate(3, (i) {
                  final positions = [
                    const Offset(-20, -15),
                    const Offset(25, 10),
                    const Offset(-10, 30),
                  ];
                  return Positioned(
                    left: 60 + positions[i].dx,
                    top: 60 + positions[i].dy,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sun.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('No reports yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.tx)),
        const SizedBox(height: 8),
        Text(
          'When your Acharyaji prepares a report for you, it appears here automatically. We\'ll notify you.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.tx2, height: 1.55),
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => Get.find<HomeController>().changeNav(3),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.sun2, AppColors.sun],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sun.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text('Contact your Acharyaji',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1205))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Report types preview (dimmed)
        Text('REPORTS YOUR ACHARYAJI CAN PREPARE',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.tx3,
                letterSpacing: 1.4)),
        const SizedBox(height: 14),
        ..._reportTypes.map((rt) => Opacity(
              opacity: 0.75,
              child: _ReportCard(rt: rt),
            )),
      ],
    );
  }
}
