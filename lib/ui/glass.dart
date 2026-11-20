import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'tokens.dart';

/// Frosted-glass card (prototype `.card`: rgba(255,255,255,.055) fill,
/// 1px rgba(255,255,255,.09) border, backdrop-filter: blur(14px)).
///
/// Uses [BackdropFilter.grouped] so all cards inside one [BackdropGroup]
/// share a single blur pass — a ListView of plain BackdropFilters would
/// re-blur the whole screen once per card and drop frames on mid-range
/// Android phones.
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double blur;

  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = kRadius,
    this.color,
    this.gradient,
    this.borderColor,
    this.blur = 14,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: br,
            color: gradient == null ? (color ?? AppColors.card) : null,
            gradient: gradient,
            border: Border.all(color: borderColor ?? AppColors.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small uppercase caption + optional right-hand note (prototype `.cap`).
class CardHeader extends StatelessWidget {
  final String title;
  final String? note;
  final Widget? trailing;
  const CardHeader(this.title, {super.key, this.note, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title.toUpperCase(), style: T.cap)),
        if (note != null) Text(note!, style: T.small),
        if (trailing != null) trailing!,
      ],
    );
  }
}
