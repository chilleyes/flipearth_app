import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class TripSkeletonCard extends StatelessWidget {
  const TripSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        children: [
          // Image skeleton
          ShimmerSkeleton(
            width: double.infinity,
            height: 180,
            borderRadius: 0,
          ),
          
          // Content skeleton
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                ShimmerSkeleton(width: 200, height: 24),
                SizedBox(height: 8),
                // Subtitle
                ShimmerSkeleton(width: 140, height: 16),
                SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ShimmerSkeleton(width: double.infinity, height: 48, borderRadius: 12),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ShimmerSkeleton(width: double.infinity, height: 48, borderRadius: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TicketSkeletonCard extends StatelessWidget {
  const TicketSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        children: [
          // Upper half
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 80, height: 20, borderRadius: 4),
                    ShimmerSkeleton(width: 50, height: 24, borderRadius: 6),
                  ],
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 80, height: 40, borderRadius: 8), // LON
                    ShimmerSkeleton(width: 60, height: 16, borderRadius: 4), // TIME
                    ShimmerSkeleton(width: 80, height: 40, borderRadius: 8), // PAR
                  ],
                ),
                SizedBox(height: 12),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 100, height: 16, borderRadius: 4),
                    ShimmerSkeleton(width: 100, height: 16, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider space
          SizedBox(height: 32),
          
          // Lower half
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                ShimmerSkeleton(width: 110, height: 110, borderRadius: 12),
                SizedBox(height: 24),
                ShimmerSkeleton(width: double.infinity, height: 54, borderRadius: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
