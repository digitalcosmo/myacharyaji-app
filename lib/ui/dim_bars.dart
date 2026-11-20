import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/five_d.dart';
import 'motion.dart';
import 'stroke_icon.dart';
import 'tokens.dart';

/// Tinted rounded square holding a dimension icon.
class DimBadge extends StatelessWidget {
  final Dim dim;
  final double size;
  const DimBadge(this.dim, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dim.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: StrokeIcon(dim.icon, color: dim.color, size: size * 0.5),
    );
  }
}

/// The five horizontal 5D bars (prototype `bars()`): bars grow from zero with
/// a staggered 1.1 s ease, and glide to new values when the period changes.
class DimBars extends StatelessWidget {
  final FiveD data;
  const DimBars(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kDims.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
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
    return Row(
      children: [
        DimBadge(dim),
        const SizedBox(width: 12),
        SizedBox(width: 72, child: Text(dim.label, style: T.label)),
        Expanded(child: AnimatedBar(value: value, color: dim.color, delayMs: index * 90)),
        const SizedBox(width: 14),
        SizedBox(
          width: 44,
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedPercent(value: value, style: T.pct),
          ),
        ),
      ],
    );
  }
}

/// A 10 px rounded track with a gradient fill (prototype `.fill`).
class AnimatedBar extends StatefulWidget {
  final double value; // 0..100
  final Color color;
  final int delayMs;
  final double height;
  const AnimatedBar({
    super.key,
    required this.value,
    required this.color,
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
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: const Duration(milliseconds: 1100),
        curve: kEase,
        builder: (_, v, __) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                colors: [widget.color.withValues(alpha: 0.55), widget.color],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth / Mixed / Careful legend.
class ToneLegend extends StatelessWidget {
  const ToneLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final t in Tone.values) ...[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: toneColor(t), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(toneLabel(t), style: T.small.copyWith(color: toneColor(t))),
          if (t != Tone.values.last) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
