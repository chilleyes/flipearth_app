import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TimeAwareParallaxHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final BuildContext context;

  TimeAwareParallaxHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.context,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent); // 0.0 (expanded) to 1.0 (collapsed)
    final safeProgress = progress.clamp(0.0, 1.0);

    final now = DateTime.now();
    final hour = now.hour;
    
    // Time-based environment
    bool isNight = hour >= 19 || hour < 6;
    bool isDusk = hour >= 17 && hour < 19;
    
    List<Color> skyGradient;
    if (isNight) {
      skyGradient = [const Color(0xFF0F172A), const Color(0xFF1E3A8A)];
    } else if (isDusk) {
      skyGradient = [Colors.orange.shade400, Colors.purple.shade900];
    } else {
      skyGradient = [Colors.blue.shade400, Colors.lightBlue.shade100];
    }

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
        // Layer 0: Sky Gradient (Background)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: skyGradient,
            ),
          ),
        ),

        // Layer 0.5: Stars (if night)
        if (isNight)
          CustomPaint(
            painter: _StarsPainter(progress: safeProgress),
            size: Size.infinite,
          ),

        // Layer 1: Midground (Distant Mountains) - moves slower
        Positioned(
          left: -40,
          right: -40,
          bottom: -50 + (safeProgress * 50), // Parallax translation
          child: Opacity(
            opacity: 1.0 - (safeProgress * 0.5),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=1200',
              fit: BoxFit.cover,
              height: 300,
              color: isNight ? Colors.black.withOpacity(0.5) : (isDusk ? Colors.deepPurple.withOpacity(0.3) : Colors.transparent),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),

        // Layer 2: Gradient Overlay to blend with solid Scaffold background
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.background.withOpacity(0.0),
                  context.colors.background.withOpacity(1.0),
                ],
              ),
            ),
          ),
        ),

        // Layer 3: Foreground Content (Title & Actions)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '探索灵感',
                style: context.textStyles.h1.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 2)),
                  ]
                ),
              ),
              GestureDetector(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.bell,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Pinned AppBar Overlay (Appears when collapsed)
        Opacity(
          opacity: safeProgress,
          child: Container(
            color: context.colors.background,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '探索灵感',
                  style: context.textStyles.h1.copyWith(fontSize: 28),
                ),
                GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.bell,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double progress;

  _StarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8 - (progress * 0.8));
    final random = math.Random(42); // Seed for consistent stars

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      
      // Twinkle effect based on progress (parallax scroll)
      final twinkle = math.sin((progress * 10) + i) * 0.5 + 0.5;
      paint.color = Colors.white.withOpacity((0.3 + twinkle * 0.7) * (1.0 - progress));
      
      canvas.drawCircle(Offset(x, y - (progress * 20)), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
