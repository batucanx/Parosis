import 'dart:ui';
import 'package:flutter/material.dart';

/// index.css `.glass` — genel katmanlı buz paneli.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.93),
                const Color(0xFFF1FAF8).withOpacity(0.78),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.92),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF083E38).withOpacity(0.14),
                blurRadius: 24,
                spreadRadius: -12,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF1F8F76).withOpacity(0.10),
                blurRadius: 14,
                spreadRadius: -8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// index.css `.glass-soft` — daha hafif blur, PageHeading geri butonu gibi yerlerde.
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
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.94),
                const Color(0xFFF5FBFA).withOpacity(0.80),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.94),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF083E38).withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: -10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// index.css `.glass-nav` — en derin bulanıklık, yüzen alt navigasyon çubuğu.
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
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.72),
                Colors.white.withOpacity(0.46),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF083E38).withOpacity(0.18),
                blurRadius: 30,
                spreadRadius: -10,
                offset: const Offset(0, -2),
              ),
              BoxShadow(
                color: const Color(0xFF083E38).withOpacity(0.4),
                blurRadius: 45,
                spreadRadius: -20,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
