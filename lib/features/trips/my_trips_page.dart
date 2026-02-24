import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../itinerary/itinerary_detail_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripCard(context),
                  // Additional space if there were more cards
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderLight,
          height: 1,
        ),
      ),
      title: Text(
        '我的行程',
        style: AppTextStyles.h1.copyWith(fontSize: 28),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ItineraryDetailPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.brandBlue.withOpacity(0.4), width: 2), // Highlight for LIVE
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlue.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top Image Section
            SizedBox(
              height: 180, // Taller image area to hold dashboard data
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?auto=format&fit=crop&q=80&w=1000',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // 'LIVE' Pill
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildLivePill(),
                  ),
                  // Weather & Currency Row
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _buildGlassWidget(PhosphorIconsFill.cloudSun, '18°C'),
                        const SizedBox(width: 8),
                        _buildGlassWidget(PhosphorIconsFill.currencyEur, '1:1.15'),
                      ],
                    ),
                  ),
                  // Progress Bar overlay at the bottom of the image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildLiveProgressBar(),
                  ),
                ],
              ),
            ),
            // Bottom Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '伦敦 & 巴黎 双城之旅',
                    style: AppTextStyles.h2.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '10月1日 - 10月7日 · 2城7天',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.background, // slate-50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.borderLight),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            '查看地图',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.brandBlue.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            '继续规划',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '行程中 (LIVE)',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassWidget(IconData icon, String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(text, style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveProgressBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: Colors.black.withOpacity(0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('伦敦', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                   Text('预计 45 分钟后抵达', style: AppTextStyles.caption.copyWith(color: AppColors.brandBlue, fontWeight: FontWeight.bold)),
                   Text('巴黎', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                 ],
               ),
               const SizedBox(height: 12),
               LayoutBuilder(
                 builder: (context, constraints) {
                   const progress = 0.7;
                   return Stack(
                     clipBehavior: Clip.none,
                     alignment: Alignment.centerLeft,
                     children: [
                       Container(
                         height: 4,
                         width: constraints.maxWidth,
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(2),
                         ),
                       ),
                       Container(
                         height: 4,
                         width: constraints.maxWidth * progress,
                         decoration: BoxDecoration(
                           color: AppColors.brandBlue,
                           borderRadius: BorderRadius.circular(2),
                           boxShadow: [
                             BoxShadow(color: AppColors.brandBlue.withOpacity(0.8), blurRadius: 8),
                           ],
                         ),
                       ),
                       Positioned(
                         left: (constraints.maxWidth * progress) - 12.0,
                         child: Container(
                           padding: const EdgeInsets.all(4),
                           decoration: const BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                           ),
                           child: const Icon(PhosphorIconsFill.train, color: AppColors.brandBlue, size: 14),
                         ),
                       ),
                     ],
                   );
                 }
               ),
            ],
          ),
        ),
      ),
    );
  }
}
