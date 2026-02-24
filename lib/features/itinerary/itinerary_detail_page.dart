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

class _ItineraryDetailPageState extends State<ItineraryDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TransformationController _mapTransformationController;
  late AnimationController _mapPanController;
  late AnimationController _pulseController;
  late PageController _mapPageController;
  Animation<Matrix4>? _mapPanAnimation;
  int _currentMapIndex = 0;

  final List<Offset> _mapPoints = const [
    Offset(300, 300), // London
    Offset(400, 375), // Train Route Center
    Offset(500, 450), // Paris
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mapTransformationController = TransformationController();
    _mapPanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _mapPageController = PageController(viewportFraction: 0.85);

    _mapPanController.addListener(() {
      if (_mapPanAnimation != null) {
        _mapTransformationController.value = _mapPanAnimation!.value;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateMapTo(_mapPoints[0], scale: 1.5);
    });
  }

  void _animateMapTo(Offset mapCenter, {double scale = 1.3}) {
    if (!mounted) return;
    // Assume screen size roughly
    final screenCenter = Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    final targetMatrix = Matrix4.identity()
      ..translate(screenCenter.dx - mapCenter.dx * scale, screenCenter.dy - mapCenter.dy * scale)
      ..scale(scale);

    _mapPanAnimation = Matrix4Tween(
      begin: _mapTransformationController.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(parent: _mapPanController, curve: Curves.easeInOutCubic));

    _mapPanController.forward(from: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapTransformationController.dispose();
    _mapPanController.dispose();
    _pulseController.dispose();
    _mapPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
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
      backgroundColor: context.colors.background,
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
                    context.colors.background,
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
                    style: context.textStyles.h1.copyWith(
                      color: context.colors.textMain, // In original it was slate-900 but over gradient it should be dark if background becomes white at bottom
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
            style: context.textStyles.caption.copyWith(
              color: context.colors.textMain,
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
                indicatorColor: context.colors.textMain,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: context.colors.textMain,
                unselectedLabelColor: context.colors.textMuted,
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
              color: context.colors.background,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.textMain, width: 3),
            ),
          ),
          lineColor: context.colors.borderLight,
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
              color: context.colors.brandBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.colors.brandBlue.withOpacity(0.3),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(PhosphorIconsFill.train, color: Colors.white, size: 12),
          ),
          lineColor: context.colors.brandBlue,
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
            style: context.textStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              subtitle,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.textMuted,
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
          border: Border.all(color: context.colors.borderLight),
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
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.brandBlue,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: context.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.textMuted,
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
                              color: context.colors.brandBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI 优选交通',
                              style: context.textStyles.caption.copyWith(
                                color: context.colors.brandBlue,
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
                                style: context.textStyles.h2.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Icon(PhosphorIconsBold.arrowRight, color: context.colors.textMuted, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '巴黎',
                                style: context.textStyles.h2.copyWith(color: Colors.white),
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
                              style: context.textStyles.caption.copyWith(
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
                      Icon(PhosphorIconsFill.clock, color: context.colors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '2h 16m',
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(PhosphorIconsFill.arrowsMerge, color: context.colors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '直达列车',
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
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
                      color: context.colors.brandBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.brandBlue.withOpacity(0.3),
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
                          style: context.textStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '€55 起',
                          style: context.textStyles.bodyMedium.copyWith(
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
        // Map Base (InteractiveViewer)
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _mapTransformationController,
            constrained: false,
            minScale: 0.5,
            maxScale: 3.0,
            child: SizedBox(
              width: 800,
              height: 800,
              child: Stack(
                children: [
                  // Map Image 800x800
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800', 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.colors.background.withOpacity(0.8),
                            Colors.transparent,
                            context.colors.background.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Trajectory curve and pulsing dot
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _TrajectoryCurvePainter(
                            activePoint: _mapPoints[_currentMapIndex],
                            pulseValue: _pulseController.value,
                            baseColor: context.colors.brandBlue,
                          ),
                        );
                      },
                    ),
                  ),
                  // Map Pin 1 (London)
                  Positioned(
                    top: _mapPoints[0].dy - 40,
                    left: _mapPoints[0].dx - 40,
                    child: _buildMapPin(
                      title: '🇬🇧 Day 1-2',
                      isActive: _currentMapIndex == 0,
                    ),
                  ),
                  // Map Pin 2 (Paris)
                  Positioned(
                    top: _mapPoints[2].dy - 40,
                    left: _mapPoints[2].dx - 40,
                    child: _buildMapPin(
                      title: '🇫🇷 Day 3-7',
                      isActive: _currentMapIndex == 2,
                      isDark: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Horizontal PageView for interaction
        Positioned(
          bottom: 120, // above FAB space
          left: 0,
          right: 0,
          height: 160,
          child: PageView(
            controller: _mapPageController,
            onPageChanged: (index) {
              setState(() => _currentMapIndex = index);
              _animateMapTo(_mapPoints[index], scale: index == 1 ? 1.0 : 1.3);
            },
            children: [
              _buildMapDayCard('Day 1 - 2', '伦敦深度探索', '大英博物馆、伦敦眼'),
              _buildMapTrainCard(),
              _buildMapDayCard('Day 3 - 7', '巴黎浪漫之行', '卢浮宫、埃菲尔铁塔', isDark: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPin({required String title, required bool isActive, bool isDark = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? context.colors.textMain : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Text(
            title,
            style: context.textStyles.caption.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : context.colors.textMain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDark ? context.colors.textMain : context.colors.brandBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: isActive
              ? Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? context.colors.brandBlue : Colors.white, shape: BoxShape.circle))
              : null,
        ),
      ],
    );
  }

  Widget _buildMapDayCard(String dayStr, String title, String subtitle, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? context.colors.textMain.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white24 : Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayStr,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.brandBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: context.textStyles.h2.copyWith(color: isDark ? Colors.white : context.colors.textMain, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textStyles.bodyMedium.copyWith(color: isDark ? Colors.white70 : context.colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapTrainCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingPage()));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [context.colors.brandBlue, const Color(0xFF2563EB)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.train, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('跨国交通', style: context.textStyles.caption.copyWith(color: context.colors.brandBlue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('伦敦', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Icon(PhosphorIconsBold.arrowRight, color: context.colors.textMuted, size: 14),
                            const SizedBox(width: 8),
                            Text('巴黎', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('推荐 EUROSTAR 欧洲之星直达列车', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            backgroundColor: context.colors.textMain, // slate-900
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
  final Offset activePoint;
  final double pulseValue;
  final Color baseColor;

  _TrajectoryCurvePainter({required this.activePoint, required this.pulseValue, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw track path
    final paint = Paint()
      ..color = baseColor.withOpacity(0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(300, 300); // London
    path.quadraticBezierTo(400, 250, 500, 450); // Paris

    canvas.drawPath(path, paint);

    // 2. Draw pulsing dot around activePoint
    final pulsePaint = Paint()
      ..color = baseColor.withOpacity(0.5 * (1.0 - pulseValue))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(activePoint, 10 + (25 * pulseValue), pulsePaint);
    
    // Core dot
    final corePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(activePoint, 8, corePaint);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryCurvePainter oldDelegate) {
    return oldDelegate.activePoint != activePoint || oldDelegate.pulseValue != pulseValue;
  }
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
