import 'dart:async';

import 'package:flutter/material.dart';

const expressiveDuration = Duration(milliseconds: 520);
const expressiveFastDuration = Duration(milliseconds: 260);
const expressiveCurve = Easing.emphasizedDecelerate;
const expressiveExitCurve = Easing.emphasizedAccelerate;

class ExpressiveSwitcher extends StatelessWidget {
  const ExpressiveSwitcher({
    super.key,
    required this.child,
    this.duration = expressiveDuration,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: expressiveFastDuration,
      switchInCurve: expressiveCurve,
      switchOutCurve: expressiveExitCurve,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: expressiveCurve,
          reverseCurve: expressiveExitCurve,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, .035),
          end: Offset.zero,
        ).animate(curved);
        final scale = Tween<double>(begin: .98, end: 1).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: offset,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class ExpressivePageSwitcher extends StatelessWidget {
  const ExpressivePageSwitcher({
    super.key,
    required this.child,
    this.duration = expressiveFastDuration,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: Duration.zero,
      switchInCurve: expressiveCurve,
      switchOutCurve: expressiveExitCurve,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: expressiveCurve,
          reverseCurve: expressiveExitCurve,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, .025),
          end: Offset.zero,
        ).animate(curved);

        return Material(
          color: colors.surfaceContainerLowest,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(position: offset, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class ExpressiveReveal extends StatefulWidget {
  const ExpressiveReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 18,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<ExpressiveReveal> createState() => _ExpressiveRevealState();
}

class _ExpressiveRevealState extends State<ExpressiveReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: expressiveDuration,
    );
    _animation = CurvedAnimation(parent: _controller, curve: expressiveCurve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final value = _animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * widget.offset),
            child: Transform.scale(
              scale: .98 + (.02 * value),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ExpressiveSection extends StatelessWidget {
  const ExpressiveSection({
    super.key,
    required this.title,
    required this.children,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExpressiveReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          AnimatedContainer(
            duration: expressiveFastDuration,
            curve: expressiveCurve,
            margin: margin,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .32),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedSize(
              duration: expressiveDuration,
              curve: expressiveCurve,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: colors.outlineVariant.withValues(alpha: .42),
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpressiveIconContainer extends StatelessWidget {
  const ExpressiveIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.foregroundColor,
    this.size = 52,
    this.radius = 18,
  });

  final IconData icon;
  final Color? color;
  final Color? foregroundColor;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        icon,
        color: foregroundColor ?? colors.onPrimaryContainer,
        size: size * .48,
      ),
    );
  }
}

class ExpressiveStatusPill extends StatelessWidget {
  const ExpressiveStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? colors.onTertiaryContainer;
    return AnimatedContainer(
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
