import 'package:flutter/material.dart';

/// cubic-bezier(.22,1,.36,1) — the prototype's single easing curve.
const Curve kEase = Cubic(.22, 1, .36, 1);

/// Fades + lifts a child into place after [delay] (prototype `.stagger`).
/// Replays whenever the widget is rebuilt with a new [Key].
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offsetY = 16,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (_, child) {
        final v = _t.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * widget.offsetY),
            child: Transform.scale(scale: 0.98 + 0.02 * v, child: child),
          ),
        );
      },
    );
  }
}

/// Scale-and-fade pop (prototype `@keyframes pop`), used by calendar cells.
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: kEase);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _t,
      child: ScaleTransition(
        scale: Tween(begin: 0.6, end: 1.0).animate(_t),
        child: widget.child,
      ),
    );
  }
}

/// Wraps each child in [FadeSlideIn] with a growing delay.
List<Widget> staggered(List<Widget> children, {int stepMs = 70, int startMs = 0}) => [
      for (var i = 0; i < children.length; i++)
        FadeSlideIn(
          delay: Duration(milliseconds: startMs + i * stepMs),
          child: children[i],
        ),
    ];

/// Scales down slightly while pressed — every tappable card uses this.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const Pressable({super.key, required this.child, this.onTap, this.pressedScale = 0.97});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 150),
        curve: kEase,
        child: widget.child,
      ),
    );
  }
}

/// Number that counts up/down to [value] (used beside every bar).
class AnimatedPercent extends StatelessWidget {
  final double value;
  final TextStyle style;
  final Duration duration;
  final String suffix;
  const AnimatedPercent({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1100),
    this.suffix = '%',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: kEase,
      builder: (_, v, __) => Text('${v.round()}$suffix', style: style),
    );
  }
}
