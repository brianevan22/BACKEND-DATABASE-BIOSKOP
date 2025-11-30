import 'package:flutter/material.dart';

class BubbleContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool gradient;
  final bool elevated;
  final Color? color;

  const BubbleContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 24,
    this.gradient = false,
    this.elevated = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surface = color ?? cs.surface;
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: gradient ? null : surface.withOpacity(gradient ? 0 : .95),
        gradient: gradient
            ? LinearGradient(
                colors: [
                  cs.primaryContainer.withOpacity(.88),
                  cs.surface.withOpacity(.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(color: cs.primary.withOpacity(.10), width: 1.2),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: cs.primary.withOpacity(.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: cs.primary.withOpacity(.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
