import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable card widget with Gen-Z styling
/// Supports elevation, padding, and tap handling
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.border,
  });

  /// Card with gradient background
  const AppCard.gradient({
    super.key,
    required this.child,
    required this.gradient,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.border,
  }) : color = null;

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);

    Widget cardChild = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    // If gradient is provided, use Container with decoration
    if (gradient != null) {
      cardChild = Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: defaultBorderRadius,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: defaultBorderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: defaultBorderRadius,
            child: cardChild,
          ),
        ),
      );

      return Container(
        margin: margin,
        child: cardChild,
      );
    }

    // Otherwise use standard Card widget
    return Container(
      margin: margin,
      child: Card(
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
          side: border != null ? border!.top : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultBorderRadius,
          child: cardChild,
        ),
      ),
    );
  }
}

/// Glassmorphic card with frosted glass effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: opacity)
                  : Colors.black.withValues(alpha: opacity),
              borderRadius: defaultBorderRadius,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: defaultBorderRadius,
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
