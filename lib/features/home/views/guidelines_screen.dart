import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/mock_data.dart';
import '../../../widgets/glass_card.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockData.guidelines;
    return Scaffold(
      appBar: AppBar(title: const Text('Guidelines')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final g = items[i];
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g['title'] ?? '', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(g['description'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}
