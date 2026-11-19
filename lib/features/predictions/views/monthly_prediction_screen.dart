import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/dimension_bar.dart';

class MonthlyPredictionScreen extends StatelessWidget {
  const MonthlyPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.monthlyData;
    final dims = data['dimensions'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['month'] ?? '', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Overall: ${data['overallScore']}',
                  style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.astronomicalBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('5D Breakdown', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...dims.map((d) => DimensionBar(dimension: d['key'], label: d['label'], score: d['score'])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (data['summary'] != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(data['summary'], style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
