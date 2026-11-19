import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          return const Center(child: CircularProgressIndicator(color: AppColors.sun));
        }
        if (rc.reportList.isEmpty) {
          return _EmptyState();
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Reports', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.tx)),
            const SizedBox(height: 4),
            Text('${rc.reportList.length} member report${rc.reportList.length == 1 ? '' : 's'} available',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx3)),
            const SizedBox(height: 20),

            // Member selector
            if (rc.reportList.length > 1) ...[
              Text('SELECT MEMBER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.tx3, letterSpacing: 1.4)),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: rc.reportList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final m = rc.reportList[i];
                    final sel = rc.selectedIndex.value == i;
                    return GestureDetector(
                      onTap: () => rc.selectMember(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: sel ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
                          border: Border.all(color: sel ? AppColors.sun : AppColors.line),
                        ),
                        child: Center(
                          child: Text(m['Name'] ?? '', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppColors.sun : AppColors.tx2)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Report type cards
            ..._reportTypes.map((rt) => _ReportCard(rt: rt)),
          ],
        );
      }),
    );
  }
}

final _reportTypes = [
  {'key': 'blueprint', 'title': 'Blueprint', 'sub': 'Your cosmic DNA — birth chart decoded', 'icon': Icons.architecture},
  {'key': 'trajectory', 'title': 'Trajectory', 'sub': 'Life timeline — planetary transits ahead', 'icon': Icons.timeline},
  {'key': 'vibes', 'title': 'Vibes', 'sub': 'Monthly emotional & social weather', 'icon': Icons.waves},
  {'key': 'intensity', 'title': 'Intensity', 'sub': 'Peak & low energy windows', 'icon': Icons.flash_on},
  {'key': 'planner', 'title': 'Planner', 'sub': 'Daily action plan across 5 dimensions', 'icon': Icons.calendar_month},
];

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> rt;
  const _ReportCard({required this.rt});

  @override
  Widget build(BuildContext context) {
    final key = rt['key'] as String;
    final grad = AppColors.reportGradients[key] ?? [AppColors.sun, AppColors.sun2];

    return GestureDetector(
      onTap: () => Get.toNamed('/report-reader', arguments: {'type': key}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.card,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  (grad[0] as Color).withValues(alpha: 0.22),
                  (grad[1] as Color).withValues(alpha: 0.08),
                ]),
              ),
              child: Icon(rt['icon'] as IconData, color: grad[0] as Color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rt['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.tx)),
                  const SizedBox(height: 2),
                  Text(rt['sub'] as String, style: GoogleFonts.inter(fontSize: 13, color: AppColors.tx3)),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sun.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.auto_stories_outlined, color: AppColors.sun, size: 36),
            ),
            const SizedBox(height: 20),
            Text('No reports yet', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx)),
            const SizedBox(height: 8),
            Text('Ask your Acharyaji to prepare your first cosmic report.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.tx3, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
