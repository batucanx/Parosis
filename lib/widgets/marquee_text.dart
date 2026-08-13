import 'dart:math' as math;

import 'package:flutter/material.dart';

class MarqueeText extends StatelessWidget {
  static const double _glyphEdgePadding = 4;

  final String text;
  final TextStyle style;
  final double overflowTolerance;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.overflowTolerance = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final textScaler = MediaQuery.textScalerOf(context);
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          textScaler: textScaler,
          maxLines: 1,
        )..layout();

        final availableWidth = constraints.maxWidth;
        final measuredOverflow = availableWidth.isFinite
            ? math.max(0.0, painter.width - availableWidth)
            : 0.0;

        if (measuredOverflow <= 0.5) {
          return Text(
            text,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          );
        }

        if (measuredOverflow <= overflowTolerance) {
          return SizedBox(
            width: availableWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(text, style: style, maxLines: 1, softWrap: false),
            ),
          );
        }

        if (MediaQuery.disableAnimationsOf(context)) {
          return Semantics(
            label: text,
            child: ExcludeSemantics(
              child: Text(
                text,
                style: style,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        final contentWidth = painter.width + (_glyphEdgePadding * 2);
        final travelDistance = contentWidth - availableWidth;

        return Semantics(
          label: text,
          child: ExcludeSemantics(
            child: SizedBox(
              width: availableWidth,
              height: painter.height + 2,
              child: _OverflowMarquee(
                text: text,
                style: style,
                distance: travelDistance,
                contentWidth: contentWidth,
                glyphEdgePadding: _glyphEdgePadding,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverflowMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double distance;
  final double contentWidth;
  final double glyphEdgePadding;

  const _OverflowMarquee({
    required this.text,
    required this.style,
    required this.distance,
    required this.contentWidth,
    required this.glyphEdgePadding,
  });

  @override
  State<_OverflowMarquee> createState() => _OverflowMarqueeState();
}

class _OverflowMarqueeState extends State<_OverflowMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _configureAnimation();
  }

  @override
  void didUpdateWidget(covariant _OverflowMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distance != widget.distance ||
        oldWidget.contentWidth != widget.contentWidth ||
        oldWidget.text != widget.text ||
        oldWidget.style != widget.style) {
      _configureAnimation();
    }
  }

  void _configureAnimation() {
    const startPauseMs = 1500;
    const endPauseMs = 1100;
    final travelMs = math.max(1800, (widget.distance / 28 * 1000).round());
    final totalMs = startPauseMs + travelMs + endPauseMs + travelMs;

    _controller
      ..stop()
      ..duration = Duration(milliseconds: totalMs)
      ..reset();

    _progress = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: startPauseMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: travelMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: endPauseMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: travelMs.toDouble(),
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        child: OverflowBox(
          minWidth: widget.contentWidth,
          maxWidth: widget.contentWidth,
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.glyphEdgePadding),
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        builder: (context, child) {
          final progress = _progress.value;
          final leftEdgeAlpha = 1 - (progress / 0.08).clamp(0.0, 1.0);
          final rightEdgeAlpha = ((progress - 0.92) / 0.08).clamp(0.0, 1.0);

          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.black.withValues(alpha: leftEdgeAlpha),
                Colors.black,
                Colors.black,
                Colors.black.withValues(alpha: rightEdgeAlpha),
              ],
              stops: const [0, 0.045, 0.955, 1],
            ).createShader(bounds),
            child: Transform.translate(
              offset: Offset(-widget.distance * progress, 0),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
