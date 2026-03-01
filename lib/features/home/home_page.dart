import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/trip.dart';
import '../../core/providers/service_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/spring_button.dart';
import '../../core/widgets/route_inspiration_card.dart';
import '../plan/plan_step1_page.dart';
import '../booking/booking_page.dart';
import '../trips/trip_detail_page.dart';
import '../visa/visa_export_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tripService = ServiceProvider().tripService;
  TripSummary? _activeTrip;
  bool _loadingTrip = true;

  @override
  void initState() {
    super.initState();
    _loadActiveTrip();
  }

  Future<void> _loadActiveTrip() async {
    try {
      final result = await _tripService.getTrips(page: 1, status: 'active');
      if (mounted) {
        setState(() {
          _activeTrip = result.items.isNotEmpty ? result.items.first : null;
          _loadingTrip = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTrip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroSection(colors, textStyles),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildDirectSearchEntry(colors, textStyles),
                  const SizedBox(height: 24),
                  if (!_loadingTrip && _activeTrip != null) ...[
                    _buildContinueTripCard(colors, textStyles),
                    const SizedBox(height: 24),
                  ],
                  _buildVisaExportEntry(colors, textStyles),
                  const SizedBox(height: 36),
                  _buildInspirationSection(colors, textStyles),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 40,
          left: 24,
          right: 24,
          bottom: 40,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0C1B2A),
              colors.brandBlue.withOpacity(0.15),
              colors.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.brandBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.globe(), size: 14, color: colors.brandBlue),
                      const SizedBox(width: 4),
                      Text(
                        'FlipEarth',
                        style: textStyles.caption.copyWith(
                          color: colors.brandBlue,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 24),
            Text(
              'Plan your\nEuro Trip\nwith AI',
              style: textStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 42,
                height: 1.05,
                letterSpacing: -1.5,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            Text(
              '智能规划 · 一键购票 · 签证材料',
              style: textStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1.0,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 350.ms),
            const SizedBox(height: 32),
            SpringButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanStep1Page()),
                );
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.brandBlue, colors.purpleGlow],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.brandBlue.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.magicWand(PhosphorIconsStyle.fill),
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Start Planning',
                      style: textStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 450.ms).slideY(begin: 0.15, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectSearchEntry(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SpringButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.brandBlue.withOpacity(0.1),
                    colors.purpleGlow.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(PhosphorIcons.train(PhosphorIconsStyle.fill),
                  color: colors.brandBlue, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Train Search',
                    style: textStyles.bodyLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '搜索欧洲之星 · 不规划也能直接买票',
                    style: textStyles.bodySmall.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.arrowRight(), size: 20, color: colors.textMuted),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildContinueTripCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final trip = _activeTrip!;
    final dateFormat = DateFormat('MMM d');
    final progress = trip.totalSegments > 0
        ? trip.bookedSegments / trip.totalSegments
        : 0.0;

    return SpringButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripDetailPage(tripId: trip.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.brandBlue.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: colors.brandBlue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Active Trip',
                    style: textStyles.caption.copyWith(
                      color: colors.successGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(PhosphorIcons.arrowRight(), size: 18, color: colors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              trip.title,
              style: textStyles.h3.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${dateFormat.format(trip.startDate)} — ${dateFormat.format(trip.endDate)}  ·  ${trip.totalDays} days',
              style: textStyles.bodySmall.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: colors.borderLight,
                      color: colors.brandBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${trip.bookedSegments}/${trip.totalSegments} booked',
                  style: textStyles.caption.copyWith(
                    color: colors.brandBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 550.ms);
  }

  Widget _buildVisaExportEntry(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SpringButton(
      onTap: () {
        if (_activeTrip != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisaExportPage(tripId: _activeTrip!.id),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先创建一个行程计划')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.purpleGlow.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIcons.fileText(PhosphorIconsStyle.fill),
                  color: colors.purpleGlow, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visa Itinerary Export',
                    style: textStyles.bodyLarge.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '一键生成申根签证行程单',
                    style: textStyles.caption.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.arrowRight(), size: 18, color: colors.textMuted),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildInspirationSection(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Route Inspiration', style: textStyles.h3.copyWith(fontSize: 18)),
            Text(
              '更多',
              style: textStyles.bodySmall.copyWith(color: colors.brandBlue, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '热门路线推荐',
          style: textStyles.caption.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            children: [
              RouteInspirationCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?auto=format&fit=crop&q=80&w=400',
                title: '英法瑞经典',
                subtitle: '10天 · 3国连线',
                onTap: () {},
              ),
              RouteInspirationCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1520175480921-4edfa2983e0f?auto=format&fit=crop&q=80&w=400',
                title: '意法南部',
                subtitle: '12天浪漫游',
                onTap: () {},
              ),
              RouteInspirationCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&q=80&w=400',
                title: '德奥童话',
                subtitle: '8天深度',
                onTap: () {},
              ),
              RouteInspirationCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&q=80&w=400',
                title: '西班牙热情',
                subtitle: '7天阳光之旅',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 650.ms);
  }
}
