import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/zone_badge.dart';

class WeeklyPredictionScreen extends StatelessWidget {
  const WeeklyPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.weeklyData;
    final days = data['days'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['weekRange'] ?? '', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(data['summary'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...days.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(d['day'] ?? '', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (d['score'] as int) / 100,
                        minHeight: 10,
                        backgroundColor: AppColors.orbitLine.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(AppColors.zoneOf(d['score']).color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 30,
                    child: Text('${d['score']}', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  ZoneBadge(score: d['score'], showLabel: false),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
