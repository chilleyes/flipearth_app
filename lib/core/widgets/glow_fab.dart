import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GlowFab extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const GlowFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<GlowFab> createState() => _GlowFabState();
}

class _GlowFabState extends State<GlowFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Simulate the breathing "animate-tilt" effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Outer Glow animating opacity simulating Tailwind's `animate-tilt`
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.4 + (_controller.value * 0.4), // pulsate between 0.4 and 0.8
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.fabGlowGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
              
              // Inner Glass Card
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.textMain.withOpacity(0.9), // slate-900/90
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: AppColors.brandBlue,
                          size: 20,
                          shadows: [
                            BoxShadow(
                              color: AppColors.brandBlue.withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
