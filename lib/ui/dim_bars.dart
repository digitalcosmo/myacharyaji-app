import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/five_d.dart';
import '../models/zone.dart';
import 'controls.dart';
import 'motion.dart';
import 'stroke_icon.dart';
import 'tokens.dart';
import 'zone_icon.dart';

/// Tinted rounded square holding a dimension icon.
class DimBadge extends StatelessWidget {
  final Dim dim;
  final double size;
  const DimBadge(this.dim, {super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dim.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: dim.color.withValues(alpha: 0.25)),
      ),
      alignment: Alignment.center,
      child: StrokeIcon(dim.icon, color: dim.color, size: size * 0.54, strokeWidth: 1.8),
    );
  }
}

/// The five horizontal 5D bars. Each bar takes its colour and arrow from the
/// zone its value falls in (as in the CK reports); bars grow from zero with
/// a staggered ease and glide to new values when the period changes.
class DimBars extends StatelessWidget {
  final FiveD data;
  const DimBars(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kDims.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
            child: _DimRow(dim: kDims[i], value: data.of(kDims[i].key), index: i),
          ),
      ],
    );
  }
}

class _DimRow extends StatelessWidget {
  final Dim dim;
  final double value;
  final int index;
  const _DimRow({required this.dim, required this.value, required this.index});

  @override
  Widget build(BuildContext context) {
    final z = Zone.of(value);
    return Row(
      children: [
        DimBadge(dim),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dim.label, style: T.label),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(z.label,
                    key: ValueKey(z),
                    style: T.small.copyWith(fontSize: 11.5, color: z.color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(child: AnimatedBar(value: value, colors: z.gradient, delayMs: index * 90)),
        const SizedBox(width: 12),
        SizedBox(
          width: 42,
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedPercent(value: value, style: T.pct),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
          child: ZoneIcon(z, key: ValueKey(z), size: 24),
        ),
      ],
    );
  }
}

/// A rounded track with a gradient fill (prototype `.fill`).
class AnimatedBar extends StatefulWidget {
  final double value; // 0..100
  final List<Color> colors;
  final int delayMs;
  final double height;
  const AnimatedBar({
    super.key,
    required this.value,
    required this.colors,
    this.delayMs = 0,
    this.height = 10,
  });

  @override
  State<AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = _started ? (widget.value / 100).clamp(0.0, 1.0) : 0.0;
    final r = BorderRadius.circular(widget.height / 2);
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: r,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: const Duration(milliseconds: 1100),
        curve: kEase,
        builder: (_, v, __) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: v,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(colors: widget.colors),
              boxShadow: [BoxShadow(color: widget.colors.last.withValues(alpha: 0.35), blurRadius: 8)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "i" button that opens the 7-zone guide.
class ZoneInfoButton extends StatelessWidget {
  const ZoneInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'What the zones mean',
      child: Pressable(
        onTap: () => showZoneGuide(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.tx3)),
            alignment: Alignment.center,
            child: Text('i', style: T.small.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tx2)),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: the 5 dimensions and 7 zones, same wording as the reports.
void showZoneGuide(BuildContext context) {
  showGlassSheet(context, builder: (ctx) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reading your 5D', style: T.h2),
          const SizedBox(height: 16),
          for (final d in kDims)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                DimBadge(d, size: 32),
                const SizedBox(width: 12),
                SizedBox(width: 70, child: Text(d.label, style: T.strong.copyWith(fontSize: 14))),
                Expanded(child: Text(d.meaning, style: T.muted.copyWith(fontSize: 13.5))),
              ]),
            ),
          const SizedBox(height: 12),
          Text('7 ZONES', style: T.cap),
          const SizedBox(height: 12),
          for (final z in Zone.values.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(width: 32, child: Center(child: ZoneIcon(z, size: 26))),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: Text('${z.from}–${z.to}%', style: T.small.copyWith(fontSize: 12.5, color: AppColors.tx2)),
                ),
                SizedBox(width: 78, child: Text(z.label, style: T.strong.copyWith(fontSize: 14, color: z.color))),
                Expanded(child: Text(z.advice, style: T.muted.copyWith(fontSize: 13))),
              ]),
            ),
          const SizedBox(height: 6),
          Text('Daily 5D is for routine events, weekly for frequent events, monthly for rare events.',
              style: T.small),
        ],
      ),
    );
  });
}

/// Compact legend: the seven zone colours as a strip with Low / High.
class ZoneStrip extends StatelessWidget {
  const ZoneStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Low', style: T.small),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              for (final z in Zone.values)
                Expanded(
                  flex: z.to - z.from + 1,
                  child: Container(height: 6, margin: const EdgeInsets.symmetric(horizontal: 1), color: z.color),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text('High', style: T.small),
      ],
    );
  }
}
