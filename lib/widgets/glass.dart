import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: borderRadius,
      blur: 0,
      padding: padding,
      gradientColors: [AppColors.surface, const Color(0xFFFCFDFC)],
      borderColor: AppColors.surfaceBorder,
      shadows: elevated
          ? [
              BoxShadow(
                color: const Color(0xFF123C36).withValues(alpha: 0.10),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 4,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: const Color(0xFF123C36).withValues(alpha: 0.045),
                blurRadius: 10,
                spreadRadius: -6,
                offset: const Offset(0, 4),
              ),
            ],
      child: child,
    );
  }
}

class GlassSoft extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassSoft({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: borderRadius,
      blur: 0,
      padding: padding,
      gradientColors: [AppColors.surfaceSoft, const Color(0xFFF7FAF9)],
      borderColor: const Color(0xFFE2E9E7),
      shadows: [
        BoxShadow(
          color: const Color(0xFF123C36).withValues(alpha: 0.04),
          blurRadius: 10,
          spreadRadius: -6,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }
}

class GlassNav extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassNav({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: borderRadius,
      blur: 8,
      padding: padding,
      gradientColors: [
        Colors.white.withValues(alpha: 0.96),
        const Color(0xFFF8FAF9).withValues(alpha: 0.92),
      ],
      borderColor: const Color(0xFFDDE6E3).withValues(alpha: 0.94),
      shadows: [
        BoxShadow(
          color: const Color(0xFF123C36).withValues(alpha: 0.12),
          blurRadius: 26,
          spreadRadius: -10,
          offset: const Offset(0, 11),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 5,
          spreadRadius: -1,
          offset: const Offset(0, 2),
        ),
      ],
      child: child,
    );
  }
}

class _GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final List<Color> gradientColors;
  final Color borderColor;
  final List<BoxShadow> shadows;

  const _GlassSurface({
    required this.child,
    required this.borderRadius,
    required this.blur,
    required this.gradientColors,
    required this.borderColor,
    required this.shadows,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: _SurfaceBody(
                  borderRadius: borderRadius,
                  padding: padding,
                  gradientColors: gradientColors,
                  borderColor: borderColor,
                  child: child,
                ),
              )
            : _SurfaceBody(
                borderRadius: borderRadius,
                padding: padding,
                gradientColors: gradientColors,
                borderColor: borderColor,
                child: child,
              ),
      ),
    );
  }
}

class _SurfaceBody extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<Color> gradientColors;
  final Color borderColor;

  const _SurfaceBody({
    required this.child,
    required this.borderRadius,
    required this.padding,
    required this.gradientColors,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      border: Border.all(color: borderColor, width: 0.8),
    ),
    child: child,
  );
}
