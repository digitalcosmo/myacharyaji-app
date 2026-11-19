import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';
import '../../../widgets/dimension_bar.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = Get.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(report['reportName'] ?? 'Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['reportName'] ?? '', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(report['personName'] ?? '', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(label: report['reportType'] ?? ''),
                    const SizedBox(width: 8),
                    _InfoChip(label: report['language'] ?? ''),
                  ],
                ),
                if (report['dateRange'] != null) ...[
                  const SizedBox(height: 8),
                  Text(report['dateRange'], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Placeholder for the full report WebView / PDF viewer
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                Icon(Icons.picture_as_pdf_outlined, size: 48, color: AppColors.reportBlue.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(
                  'Report content will render here',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'WebView loads the CVPT HTML report or displays the PDF',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: open report URL in WebView or launch external
                  },
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('Open Report'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sample 5D preview (would come from report data in real app)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('5D Preview', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const DimensionBar(dimension: 'career', label: 'Career', score: 72),
                const DimensionBar(dimension: 'finance', label: 'Finance', score: 58),
                const DimensionBar(dimension: 'health', label: 'Health', score: 81),
                const DimensionBar(dimension: 'social', label: 'Social', score: 45),
                const DimensionBar(dimension: 'love', label: 'Love', score: 66),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.reportBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.reportBlue, fontWeight: FontWeight.w500)),
    );
  }
}
