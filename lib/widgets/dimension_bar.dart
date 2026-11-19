import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// Horizontal gradient bar for a 5D dimension score.
class DimensionBar extends StatelessWidget {
  final String dimension; // career, finance, health, social, love
  final String label;
  final int score; // 0-100
  final double height;

  const DimensionBar({
    super.key,
    required this.dimension,
    required this.label,
    required this.score,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dimensionGradient(dimension);
    final zone = AppColors.zoneOf(score);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text(
                '$score — ${zone.name}',
                style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: zone.color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Track
                Container(
                  height: height, width: double.infinity,
                  color: AppColors.orbitLine.withOpacity(0.3),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
