import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/load_result.dart';
import 'controls.dart';
import 'glass.dart';
import 'stroke_icon.dart';
import 'tokens.dart';

/// Shimmering placeholder block.
class Skeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;
  const Skeleton({super.key, required this.height, this.width, this.radius = 10});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value * 2 - 0.5;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2 - 0.6, 0),
              end: Alignment(-1 + t * 2 + 0.6, 0),
              colors: [
                Colors.white.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Five skeleton rows shaped like [DimBars].
class DimBarsSkeleton extends StatelessWidget {
  const DimBarsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
            child: const Row(
              children: [
                Skeleton(height: 34, width: 34, radius: 11),
                SizedBox(width: 12),
                Skeleton(height: 12, width: 64),
                SizedBox(width: 16),
                Expanded(child: Skeleton(height: 10)),
                SizedBox(width: 14),
                Skeleton(height: 14, width: 36),
              ],
            ),
          ),
      ],
    );
  }
}

/// Shown inside a card when a reading cannot be shown.
class InlineNotice extends StatelessWidget {
  final String icon;
  final Color color;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const InlineNotice({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  factory InlineNotice.locked(String message) => InlineNotice(
        icon: Ic.lock,
        color: AppColors.vio,
        title: 'Not unlocked',
        message: message,
      );

  factory InlineNotice.error(String message, VoidCallback onRetry) => InlineNotice(
        icon: Ic.refresh,
        color: AppColors.rose,
        title: 'Couldn\'t load',
        message: message,
        actionLabel: 'Try again',
        onAction: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: StrokeIcon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.strong),
                const SizedBox(height: 4),
                Text(message, style: T.muted.copyWith(fontSize: 13.5)),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  SecondaryButton(label: actionLabel!, onTap: onAction, icon: Ic.refresh),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a [FiveDResult] with the correct loading / locked / error state.
class ResultSwitch extends StatelessWidget {
  final FiveDResult? result;
  final Widget Function(FiveDResult ok) builder;
  final Widget loading;
  final VoidCallback onRetry;

  const ResultSwitch({
    super.key,
    required this.result,
    required this.builder,
    required this.onRetry,
    this.loading = const DimBarsSkeleton(),
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    Widget child;
    String k;
    if (r == null || r.status == LoadStatus.loading) {
      child = loading;
      k = 'loading';
    } else if (r.status == LoadStatus.locked) {
      child = InlineNotice.locked(r.message ?? '');
      k = 'locked';
    } else if (r.status == LoadStatus.error) {
      child = InlineNotice.error(r.message ?? '', onRetry);
      k = 'error';
    } else {
      child = builder(r);
      k = 'ok';
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      child: KeyedSubtree(key: ValueKey(k), child: child),
    );
  }
}

/// Full-width empty state with floating illustration (prototype `.empty-art`).
class EmptyState extends StatefulWidget {
  final String title;
  final String message;
  final String icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Ic.doc,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _c,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
            child: Transform.rotate(angle: -0.035 * _c.value, child: child),
          ),
          child: Glass(
            padding: const EdgeInsets.all(30),
            radius: 26,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.03)],
            ),
            child: StrokeIcon(widget.icon, color: AppColors.sun2, size: 40, strokeWidth: 1.6),
          ),
        ),
        const SizedBox(height: 24),
        Text(widget.title, style: T.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(widget.message, style: T.muted, textAlign: TextAlign.center),
        ),
        if (widget.actionLabel != null) ...[
          const SizedBox(height: 22),
          PrimaryButton(label: widget.actionLabel!, onTap: widget.onAction),
        ],
      ],
    );
  }
}
