import 'package:flutter/material.dart';

/// index.css `.screen-in` — fade + translateY(10px), 0.34s, cubic-bezier(0.22,1,0.36,1).
/// Her ekran her göründüğünde (yeniden mount edildiğinde) bir kez oynar.
class ScreenIn extends StatefulWidget {
  final Widget child;
  const ScreenIn({super.key, required this.child});

  @override
  State<ScreenIn> createState() => _ScreenInState();
}

class _ScreenInState extends State<ScreenIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(
      begin: const Offset(0, 10),
      end: Offset.zero,
    ).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(offset: _offset.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
