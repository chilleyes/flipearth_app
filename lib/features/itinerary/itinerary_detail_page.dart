import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../booking/booking_page.dart';

class ItineraryDetailPage extends StatefulWidget {
  const ItineraryDetailPage({super.key});

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(),
          _buildStickyTabBar(),
          
          // Content Area mapping to the tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false, // Custom back button
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              'https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?auto=format&fit=crop&q=80&w=1000',
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Floating Text
            Positioned(
              bottom: 24,
              left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildGlassTag('10.01 - 10.07'),
                      const SizedBox(width: 8),
                      _buildGlassTag('2 城 7 天'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '伦敦 & 巴黎\n双城漫步之旅',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textMain, // In original it was slate-900 but over gradient it should be dark if background becomes white at bottom
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Custom Top Actions (Back & Share)
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassIconButton(
            icon: PhosphorIconsBold.arrowLeft,
            onTap: () => Navigator.pop(context),
          ),
          _buildGlassIconButton(
            icon: PhosphorIconsBold.shareNetwork,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTag(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // glass-dark
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.85),
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.textMain,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.textMain,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '日程流'),
                  Tab(text: '地图模式'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        _buildDayHeader(day: 'Day 1', subtitle: '抵达伦敦 🇬🇧'),
        _buildTimelineEvent(
          isLast: false,
          indicator: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMain, width: 3),
            ),
          ),
          lineColor: AppColors.borderLight,
          child: _buildActivityCard(
            time: '10:00 AM',
            title: '大英博物馆',
            desc: '建议游玩 3 小时。重点参观罗塞塔石碑和帕特农神庙雕塑。',
            imageUrl: 'https://images.unsplash.com/photo-1574483733224-e67c824c65db?auto=format&fit=crop&q=80&w=200',
          ),
        ),
        const SizedBox(height: 20),
        _buildDayHeader(day: 'Day 3', subtitle: '跨国转移 🚂'),
        _buildTimelineEvent(
          isLast: true, // No continued line below
          indicator: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue.withOpacity(0.3),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(PhosphorIconsFill.train, color: Colors.white, size: 12),
          ),
          lineColor: AppColors.brandBlue,
          isDashed: true,
          child: _buildTrainTicketCard(),
        ),
      ],
    );
  }

  Widget _buildDayHeader({required String day, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            day,
            style: AppTextStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent({
    required Widget indicator,
    required Widget child,
    required Color lineColor,
    bool isLast = false,
    bool isDashed = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Indicator Column
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Line
                if (!isLast)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: isDashed
                          ? CustomPaint(
                              size: const Size(2, double.infinity),
                              painter: _VerticalDashedLinePainter(color: lineColor, strokeWidth: 3),
                            )
                          : Container(
                              width: 3,
                              color: lineColor,
                            ),
                    ),
                  ),
                // Indicator
                Positioned(
                  top: 0,
                  child: indicator,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 32),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String time,
    required String title,
    required String desc,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainTicketCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingPage()));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2), // Outer border gradient trick
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Train Icon watermark
              const Positioned(
                right: -24,
                top: -24,
                child: Opacity(
                  opacity: 0.03,
                  child: Icon(
                    PhosphorIconsFill.train,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI 优选交通',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '伦敦',
                                style: AppTextStyles.h2.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(PhosphorIconsBold.arrowRight, color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '巴黎',
                                style: AppTextStyles.h2.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 80,
                            height: 32,
                            color: Colors.white.withOpacity(0.1),
                            alignment: Alignment.center,
                            child: Text(
                              'EUROSTAR',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(PhosphorIconsFill.clock, color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '2h 16m',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(PhosphorIconsFill.arrowsMerge, color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '直达列车',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '查看时刻表 & 预订',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '€55 起',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
      ),
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        // Background Map Image
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay for better text contrast
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.7),
                  Colors.transparent,
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        // Dashed trajectory curve
        Positioned.fill(
          child: CustomPaint(
            painter: _TrajectoryCurvePainter(),
          ),
        ),
        // Map Pin 1
        Positioned(
          top: 120,
          left: 90,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Text(
                  '🇬🇧 Day 1-2',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
        // Map Pin 2
        Positioned(
          top: 240,
          left: 200,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.textMain, // slate-900
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Text(
                  '🇫🇷 Day 3-7',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.textMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Action Card
        Positioned(
          bottom: 120, // above FAB
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.brandBlue, Color(0xFF2563EB)], // blue-600
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsFill.train, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '跨国交通',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brandBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '伦敦',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 8),
                              const Icon(PhosphorIconsBold.arrowRight, color: AppColors.textMuted, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '巴黎',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '查看',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenu() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.textMain, // slate-900
            elevation: 10,
            onPressed: () {},
            child: const Icon(PhosphorIconsFill.magicWand, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _TrajectoryCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(100, 150);
    path.quadraticBezierTo(200, 80, 210, 260);

    // To draw dashed paths in Flutter requires a bit of math or external packages like path_drawing.
    // For simplicity without external deps, we draw a solid curved path for now, or manually dash it if it was straight.
    // Given the complexity of dashing bezier curves natively, a solid curve serves as a good approximation.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 60.0; // height of tab bar
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _VerticalDashedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = 0;

    // Start painting from slightly below top to avoid overlapping with circle.
    // In our specific case, just draw the whole line, IntrinsicHeight will clip it visually
    // since we placed it aligning to center. 
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
