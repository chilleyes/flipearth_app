import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../planner/planner_page.dart';
import 'destination_guide_page.dart';
import 'widgets/time_aware_parallax_header.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoCard(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader('AI 优选路线'),
                  const SizedBox(height: 16),
                  _buildDestinationsGrid(context),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: TimeAwareParallaxHeaderDelegate(
        expandedHeight: 280,
        collapsedHeight: MediaQuery.of(context).padding.top + 60,
        context: context,
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerPage()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // slate-900
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background blur glow
            Positioned(
              top: -60,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.2), // brand-blue glow
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            
            // Train emoji
            Positioned(
              bottom: -10,
              right: -10,
              child: Transform(
                transform: Matrix4.rotationZ(-0.26), // -15 degrees in radians
                child: const Opacity(
                  opacity: 0.1,
                  child: Text(
                    '🚂',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.brandBlue.withOpacity(0.2),
                    border: Border.all(
                      color: context.colors.brandBlue.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '限时特惠',
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.brandBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '伦敦-巴黎 直达特价',
                  style: context.textStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '本周末出发，低至 €45 起',
                  style: context.textStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsBold.ticket, size: 16, color: context.colors.textMain),
                      const SizedBox(width: 6),
                      Text(
                        '即刻抢购',
                        style: context.textStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textStyles.h3),
        Text(
          '查看全部',
          style: context.textStyles.caption.copyWith(
            color: context.colors.brandBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationGuidePage(
            heroTag: 'dest_ch',
            title: '冰川列车全景',
            subtitle: '8天7晚 · 绝美阿尔卑斯',
            country: '🇨🇭 瑞士',
            imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=400',
          ))),
          child: _buildGridItem(
            heroTag: 'dest_ch',
            imageUrl: 'https://images.unsplash.com/photo-1522083111301-4c172352163b?auto=format&fit=crop&q=80&w=400',
            country: '🇨🇭 瑞士',
            title: '冰川列车全景',
            subtitle: '8天7晚 · 绝美阿尔卑斯',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationGuidePage(
            heroTag: 'dest_fr',
            title: '南法蔚蓝海岸之旅',
            subtitle: '6天5晚 · 阳光沙滩与艺术',
            country: '🇫🇷 法国',
            imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=400',
          ))),
          child: _buildGridItem(
            heroTag: 'dest_fr',
            imageUrl: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=400',
            country: '🇫🇷 法国',
            title: '南法蔚蓝海岸之旅',
            subtitle: '6天5晚 · 阳光沙滩与艺术',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationGuidePage(
            heroTag: 'dest_it',
            title: '罗马千年漫步',
            subtitle: '5天4晚 · 沉浸式古城游',
            country: '🇮🇹 意大利',
            imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&q=80&w=400',
          ))),
          child: _buildGridItem(
            heroTag: 'dest_it',
            imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&q=80&w=400',
            country: '🇮🇹 意大利',
            title: '罗马千年漫步',
            subtitle: '5天4晚 · 沉浸式古城游',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerPage())),
          child: _buildAiGridItem(context),
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required String heroTag,
    required String imageUrl,
    required String country,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            country,
                            style: context.textStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textMuted,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiGridItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.brandBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.brandBlue.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid, // Note: Flutter doesn't have internal dashed borders out of the box in simple Container
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsFill.magicWand, color: context.colors.brandBlue, size: 32),
          const SizedBox(height: 8),
          Text(
            '让 AI 帮你制定',
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colors.brandBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '专属个性化路线',
            style: context.textStyles.caption.copyWith(
              color: context.colors.brandBlue.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
