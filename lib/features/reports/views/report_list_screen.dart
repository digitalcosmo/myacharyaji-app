import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';
import '../../../routes/app_routes.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = MockData.reportList['reports'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = reports[i];
          return GlassCard(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: () => Get.toNamed(AppRoutes.reportDetail, arguments: r),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  // Report type icon
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.reportBlue.withOpacity(0.15), AppColors.reportBlue.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_stories_outlined, color: AppColors.reportBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['reportName'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r['personName'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${r['reportType'] ?? ''} • ${r['language'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
