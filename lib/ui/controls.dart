import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'motion.dart';
import 'stroke_icon.dart';
import 'tokens.dart';

/// Segmented control with a sliding light thumb (prototype `.seg2`).
class Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final Color thumb;
  final Color selectedText;
  final double height;

  const Segmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.thumb = AppColors.tx,
    this.selectedText = const Color(0xFF0B0D1F),
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / labels.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: kEase,
              left: w * index,
              top: 0,
              bottom: 0,
              width: w,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: thumb,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: thumb.withValues(alpha: 0.25), blurRadius: 16)],
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: i == index ? selectedText : AppColors.tx2,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// Pill chip (prototype `.chip`).
class Chip2 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color accent;
  final Widget? leading;
  const Chip2({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.accent = AppColors.sun,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: kEase,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? accent.withValues(alpha: 0.55) : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.tx : AppColors.tx2,
                )),
          ],
        ),
      ),
    );
  }
}

/// Round 44 px glass icon button (prototype `.icon-btn`).
class RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? color;
  final double size;
  final String? tooltip;
  const RoundIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.color,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Pressable(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.28,
        duration: const Duration(milliseconds: 250),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(color: AppColors.line),
          ),
          alignment: Alignment.center,
          child: StrokeIcon(icon, color: color ?? AppColors.tx, size: 18),
        ),
      ),
    );
    return tooltip == null ? btn : Semantics(button: true, label: tooltip, child: btn);
  }
}

/// Gold primary button (prototype `.btn`).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool expand;
  const PrimaryButton({super.key, required this.label, this.onTap, this.expand = true});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sun2, AppColors.sun],
          ),
          boxShadow: [BoxShadow(color: AppColors.sun.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1A1205))),
      ),
    );
  }
}

/// Secondary outline button (prototype `.btn2`).
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool expand;
  final String? icon;
  const SecondaryButton({super.key, required this.label, this.onTap, this.expand = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 42,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: AppColors.sun.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.sun.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[StrokeIcon(icon!, color: AppColors.sun2, size: 16), const SizedBox(width: 8)],
            Text(label, style: T.strong.copyWith(fontSize: 14, color: AppColors.sun2)),
          ],
        ),
      ),
    );
  }
}

/// Shows a frosted bottom sheet.
Future<T?> showGlassSheet<T>(BuildContext context, {required Widget Function(BuildContext) builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.86),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF2111433),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        padding: EdgeInsets.fromLTRB(22, 10, 22, 22 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Flexible(child: builder(ctx)),
          ],
        ),
      ),
    ),
  );
}
