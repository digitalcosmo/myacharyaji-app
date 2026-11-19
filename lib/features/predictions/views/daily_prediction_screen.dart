import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';
import '../../../widgets/dimension_bar.dart';

class DailyPredictionScreen extends StatelessWidget {
  const DailyPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.dailyPrediction;
    final dims = data['dimensions'] as List;
    final rashi = data['rashi'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date + overall
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['date'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ZoneBadge(score: data['overallScore'] ?? 50),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Overall Score: ${data['overallScore']}',
                  style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.astronomicalBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5D Dimensions
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('5D Dimensions', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...dims.map((d) => DimensionBar(
                  dimension: d['key'],
                  label: d['label'],
                  score: d['score'],
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rashi info
          if (rashi != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rashi', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.reportBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (rashi['name'] as String? ?? '?')[0],
                            style: GoogleFonts.lexendGiga(fontSize: 22, color: AppColors.reportBlue, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rashi['name'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(rashi['englishName'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  if (rashi['prediction'] != null) ...[
                    const SizedBox(height: 12),
                    Text(rashi['prediction'], style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ],
                ],
              ),
            ),

          // General prediction text
          if (data['generalPrediction'] != null) ...[
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(data['generalPrediction'], style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
