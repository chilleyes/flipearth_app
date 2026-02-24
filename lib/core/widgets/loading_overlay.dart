import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LoadingOverlay extends StatefulWidget {
  final Future<void> Function() onLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.onLoading, required this.child});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> triggerLoad() async {
    setState(() => _isLoading = true);
    await widget.onLoading();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F172A), // slate-900 background
              child: Stack(
                children: [
                  // Dot Grid Background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: CustomPaint(painter: _DotGridPainter()),
                    ),
                  ),
                  // Centered Spinner Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80, height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF334155), width: 4)), // slate-700
                              ),
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _controller.value * 2 * pi,
                                    child: Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: const Border(
                                          top: BorderSide(color: Colors.transparent, width: 4),
                                          bottom: BorderSide(color: AppColors.brandBlue, width: 4),
                                          left: BorderSide(color: AppColors.brandBlue, width: 4),
                                          right: BorderSide(color: AppColors.brandBlue, width: 4),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Icon(PhosphorIconsFill.planet, color: Colors.white, size: 30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text('AI 规划中...', style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 24)),
                        const SizedBox(height: 12),
                        Text(
                          '正在为您检索伦敦与巴黎的最佳景点，\n并匹配欧洲之星时刻表',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 48),
                        // Mock Skeletons
                        Opacity(
                          opacity: 0.5,
                          child: Column(
                            children: [
                              Container(width: 260, height: 60, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16))),
                              const SizedBox(height: 12),
                              Container(width: 260, height: 60, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlue
      ..style = PaintingStyle.fill;
    
    const spacing = 20.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Create a radial opacity effect from center
        final center = Offset(size.width / 2, size.height / 2);
        final current = Offset(x, y);
        final distance = (current - center).distance;
        final maxDist = size.width / 1.5;
        final opacity = (1 - (distance / maxDist)).clamp(0.0, 1.0);

        if (opacity > 0) {
          paint.color = AppColors.brandBlue.withOpacity(opacity);
          canvas.drawCircle(current, radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
