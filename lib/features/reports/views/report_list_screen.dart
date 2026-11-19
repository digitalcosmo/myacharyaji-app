import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../routes/app_routes.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ReportController>();
    c.loadReports();

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (c.reportList.isEmpty) {
          return Center(child: Text('No members found', style: GoogleFonts.poppins(color: AppColors.textMuted)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: c.reportList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = c.reportList[i];
            return GlassCard(
              padding: const EdgeInsets.all(14),
              child: InkWell(
                onTap: () {
                  c.selectMember(i);
                  Get.toNamed(AppRoutes.dailyPrediction);
                },
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.reportBlue.withOpacity(0.15), AppColors.reportBlue.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_outline, color: AppColors.reportBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['Name'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Start: ${r['Starting_Month'] ?? ''}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Duration: ${r['Duration'] ?? ''} • ${r['IsActive'] == true ? 'Active' : 'Inactive'}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
