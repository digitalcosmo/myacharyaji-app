import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// Compact badge showing a zone name + color indicator.
class ZoneBadge extends StatelessWidget {
  final int score;
  final bool showLabel;
  final double fontSize;

  const ZoneBadge({super.key, required this.score, this.showLabel = true, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final zone = AppColors.zoneOf(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: zone.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: zone.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: zone.color),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              zone.name,
              style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w600, color: zone.color),
            ),
          ],
        ],
      ),
    );
  }
}
