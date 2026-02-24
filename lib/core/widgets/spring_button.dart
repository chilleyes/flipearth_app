import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const SpringButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: widget.child.animate(
        target: _isPressed ? 1 : 0,
        delay: _isPressed ? Duration.zero : 200.ms,
      ).scaleXY(
        begin: 1.0,
        end: 0.95,
        curve: _isPressed ? Curves.easeOutCubic : Curves.elasticOut,
        duration: _isPressed ? 100.ms : 600.ms,
      ),
    );
  }
}
