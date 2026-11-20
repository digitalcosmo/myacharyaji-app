import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'motion.dart';
import 'tokens.dart';

class ColumnItem {
  final String label;

  /// 0..100, or null while loading / unavailable.
  final double? value;
  final bool selected;
  final bool enabled;
  final bool loading;
  const ColumnItem({
    required this.label,
    this.value,
    this.selected = false,
    this.enabled = true,
    this.loading = false,
  });
}

/// Vertical bar graph (prototype `.week .b`): columns rise from the baseline
/// with a staggered ease, glide to new values, and can be tapped.
class ColumnChart extends StatelessWidget {
  final List<ColumnItem> items;
  final Color color;
  final double height;
  final ValueChanged<int>? onTap;

  const ColumnChart({
    super.key,
    required this.items,
    required this.color,
    this.height = 132,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: items[i].enabled && onTap != null ? () => onTap!(i) : null,
                child: _Column(item: items[i], color: color, height: height, index: i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Column extends StatefulWidget {
  final ColumnItem item;
  final Color color;
  final double height;
  final int index;
  const _Column({required this.item, required this.color, required this.height, required this.index});

  @override
  State<_Column> createState() => _ColumnState();
}

class _ColumnState extends State<_Column> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final v = it.value;
    final frac = (_started && v != null) ? (v / 100).clamp(0.04, 1.0) : 0.0;
    final sel = it.selected;
    final dim = !it.enabled;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedOpacity(
          opacity: (sel && v != null) ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Text(v == null ? '' : '${v.round()}%',
              style: T.small.copyWith(color: AppColors.tx, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Track
              Container(
                width: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: dim ? 0.02 : 0.04),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              if (it.loading && v == null) const _PulseStub(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: frac),
                duration: const Duration(milliseconds: 1000),
                curve: kEase,
                builder: (_, f, __) => Container(
                  width: 22,
                  height: widget.height * f,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: sel
                          ? [Color.lerp(widget.color, Colors.white, 0.35)!, widget.color]
                          : [
                              widget.color.withValues(alpha: 0.85),
                              widget.color.withValues(alpha: 0.22),
                            ],
                    ),
                    boxShadow: sel
                        ? [BoxShadow(color: widget.color.withValues(alpha: 0.45), blurRadius: 14)]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          it.label,
          style: T.small.copyWith(
            color: sel ? AppColors.tx : (dim ? AppColors.tx3.withValues(alpha: 0.4) : AppColors.tx3),
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PulseStub extends StatefulWidget {
  const _PulseStub();
  @override
  State<_PulseStub> createState() => _PulseStubState();
}

class _PulseStubState extends State<_PulseStub> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.15, end: 0.45).animate(_c),
      child: Container(
        width: 22,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }
}
