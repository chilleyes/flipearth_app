import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glow_tag.dart';
import '../../core/widgets/route_inspiration_card.dart';
import '../../core/widgets/glow_fab.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../search/station_picker_page.dart';
import '../search/widgets/passenger_selector_sheet.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  // 0: AI Route Planning, 1: Direct Train Ticket
  int _segmentedControlGroupValue = 0;
  int _selectedCompanion = 0;
  
  // Traditional Search State
  String _fromStation = '伦敦 St Pancras';
  String _toStation = '巴黎 Gare du Nord';
  DateTime? _outboundDate = DateTime.now().add(const Duration(days: 3));
  DateTime? _returnDate;
  int _adults = 1;
  int _youths = 0;
  int _children = 0;

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeroHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _segmentedControlGroupValue == 0
                            ? _buildAiPlannerForm()
                            : _buildTicketForm(),
                      ),
                    ],
                  ),
                ),
              ),
              // Extra space for FAB and bottom nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 180)),
            ],
          ),
          
          // Floating Gradient & Glow FAB Positioned safely above the bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 85, // Height of GlassBottomNavBar in MainLayout
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.9),
                    AppColors.background.withOpacity(0.0),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlowFab(
                    label: _segmentedControlGroupValue == 0 
                        ? '智能生成专属行程'
                        : '搜索欧洲之星车次',
                    icon: _segmentedControlGroupValue == 0 
                        ? PhosphorIconsRegular.magicWand
                        : PhosphorIconsRegular.train,
                    onTap: () {
                      // print("Action clicked");
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPlannerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Form core
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsRegular.paperPlaneRight,
                        color: AppColors.brandBlue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('你想去哪儿？',
                            style: AppTextStyles.bodySmall),
                        Text('欧洲多国畅游', style: AppTextStyles.h3),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
                child: SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    color: AppColors.borderLight,
                    thickness: 2,
                  ),
                ),
              ),
              // Dates
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsRegular.calendarBlank,
                        color: AppColors.textSecondary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('出发日期',
                            style: AppTextStyles.bodySmall),
                        Text('随时出发', style: AppTextStyles.h3),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Companions
        Text('和谁一起', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GlowTag(
              label: '独自一人',
              icon: PhosphorIconsRegular.user,
              isSelected: _selectedCompanion == 0,
              onTap: () => setState(() => _selectedCompanion = 0),
            ),
            GlowTag(
              label: '情侣/夫妻',
              icon: PhosphorIconsRegular.users,
              isSelected: _selectedCompanion == 1,
              onTap: () => setState(() => _selectedCompanion = 1),
            ),
            GlowTag(
              label: '朋友/同学',
              icon: PhosphorIconsRegular.beerBottle,
              isSelected: _selectedCompanion == 2,
              onTap: () => setState(() => _selectedCompanion = 2),
            ),
            GlowTag(
              label: '带小孩/老人',
              icon: PhosphorIconsRegular.baby,
              isSelected: _selectedCompanion == 3,
              onTap: () => setState(() => _selectedCompanion = 3),
            ),
          ],
        ),

        const SizedBox(height: 32),
        // Popular route inspiration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('热门路线灵感', style: AppTextStyles.h3),
            Icon(PhosphorIconsRegular.arrowRight, size: 18, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none, // Allow glow effect to bleed
            physics: const BouncingScrollPhysics(),
            children: [
              RouteInspirationCard(
                imageUrl: 'https://images.unsplash.com/photo-1533929736458-ca588d08c8be?auto=format&fit=crop&q=80&w=400',
                title: '英法瑞经典',
                subtitle: '10天连线',
                onTap: () {},
              ),
              RouteInspirationCard(
                imageUrl: 'https://images.unsplash.com/photo-1520175480921-4edfa2983e0f?auto=format&fit=crop&q=80&w=400',
                title: '意法南部',
                subtitle: '12天浪漫游',
                onTap: () {},
              ),
              RouteInspirationCard(
                imageUrl: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&q=80&w=400',
                title: '德奥童话',
                subtitle: '8天深度',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Station Row
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    _buildStationField('出发地', _fromStation, PhosphorIconsFill.mapPin, true),
                    const Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Divider(height: 24, color: AppColors.borderLight),
                    ),
                    _buildStationField('目的地', _toStation, PhosphorIconsFill.mapPinLine, false),
                  ],
                ),
                Positioned(
                  right: 16,
                  child: GestureDetector(
                    onTap: _swapStations,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(PhosphorIconsBold.arrowsDownUp, color: AppColors.brandBlue, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          // Date Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectorField(
                    '出发日期', 
                    _formatDate(_outboundDate, '选择日期'), 
                    PhosphorIconsRegular.calendarBlank,
                    () => _pickDate(true),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.borderLight),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _buildSelectorField(
                      '返程日期', 
                      _formatDate(_returnDate, '添加返程'), 
                      PhosphorIconsRegular.plusCircle,
                      () => _pickDate(false),
                      isPlaceholder: _returnDate == null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          // Passengers Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _buildSelectorField(
              '乘客与优待卡', 
              _formatPassengers(), 
              PhosphorIconsRegular.users,
              _pickPassengers,
            ),
          ),
          // Search CTA
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('查找车票', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationField(String label, String value, IconData icon, bool isFrom) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StationPickerPage(),
            fullscreenDialog: true,
          ),
        );
        if (result != null && result is String) {
          setState(() {
            if (isFrom) {
              _fromStation = result;
            } else {
              _toStation = result;
            }
          });
        }
      },
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorField(String label, String value, IconData icon, VoidCallback onTap, {bool isPlaceholder = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: isPlaceholder ? AppColors.textMain : AppColors.brandBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.bold,
                    color: isPlaceholder ? AppColors.textMain : AppColors.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isOutbound) async {
    final initialDate = isOutbound 
        ? (_outboundDate ?? DateTime.now()) 
        : (_returnDate ?? _outboundDate ?? DateTime.now());
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOutbound) {
          _outboundDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  Future<void> _pickPassengers() async {
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PassengerSelectorSheet(
        initialAdults: _adults,
        initialYouths: _youths,
        initialChildren: _children,
      ),
    );

    if (result != null) {
      setState(() {
        _adults = result['adults']!;
        _youths = result['youths']!;
        _children = result['children']!;
      });
    }
  }

  String _formatDate(DateTime? date, String fallback) {
    if (date == null) return fallback;
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
  }

  String _formatPassengers() {
    final total = _adults + _youths + _children;
    if (total == 0) return '请选择乘客';
    List<String> parts = [];
    if (_adults > 0) parts.add('$_adults 成人');
    if (_youths > 0) parts.add('$_youths 青年');
    if (_children > 0) parts.add('$_children 儿童');
    return parts.join(', ');
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&q=80&w=1000',
              fit: BoxFit.cover,
            ),
            // The Dark Gradient Mask
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
            ),
            // Text Content Overlay
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '探索您的下一站\n完美欧洲之旅',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FlipEarth 官方直连，极速出票。',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Background Pill
          AnimatedAlign(
            alignment: _segmentedControlGroupValue == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn, // Spring-like feel
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The clickable tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _segmentedControlGroupValue = 0),
                  child: Center(
                    child: _TabLabel(
                      title: 'AI 路线规划',
                      icon: PhosphorIconsRegular.magicWand,
                      isSelected: _segmentedControlGroupValue == 0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _segmentedControlGroupValue = 1),
                  child: Center(
                    child: _TabLabel(
                      title: '单独买火车票',
                      icon: PhosphorIconsRegular.train,
                      isSelected: _segmentedControlGroupValue == 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;

  const _TabLabel({
    required this.title,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(title),
        ],
      ),
    );
  }
}
