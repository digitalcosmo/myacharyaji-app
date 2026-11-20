import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/five_d.dart';

/// Type scale from the prototype (Space Grotesk headings, Inter body).
class T {
  T._();

  static TextStyle h1 = GoogleFonts.spaceGrotesk(
      fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.tx, letterSpacing: -0.6, height: 1.1);
  static TextStyle h2 = GoogleFonts.spaceGrotesk(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tx, letterSpacing: -0.3);
  static TextStyle h3 = GoogleFonts.spaceGrotesk(
      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.tx);
  static TextStyle body = GoogleFonts.inter(fontSize: 15, color: AppColors.tx, height: 1.45);
  static TextStyle muted = GoogleFonts.inter(fontSize: 14, color: AppColors.tx2, height: 1.5);
  static TextStyle small = GoogleFonts.inter(fontSize: 12.5, color: AppColors.tx3, height: 1.4);
  static TextStyle label = GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.tx);
  static TextStyle strong = GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tx);
  static TextStyle cap = GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tx3, letterSpacing: 1.6);
  static TextStyle pct = GoogleFonts.spaceGrotesk(
      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.tx);
}

const double kRadius = 22;
const EdgeInsets kPagePad = EdgeInsets.fromLTRB(20, 0, 20, 0);

Color toneColor(Tone t) {
  switch (t) {
    case Tone.smooth:
      return AppColors.teal;
    case Tone.mixed:
      return AppColors.sun;
    case Tone.careful:
      return AppColors.rose;
  }
}

String toneLabel(Tone t) {
  switch (t) {
    case Tone.smooth:
      return 'Smooth';
    case Tone.mixed:
      return 'Mixed';
    case Tone.careful:
      return 'Careful';
  }
}
