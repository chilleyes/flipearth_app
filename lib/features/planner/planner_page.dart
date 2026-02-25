import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glow_tag.dart';
import '../../core/widgets/route_inspiration_card.dart';
import '../../core/widgets/glow_fab.dart';
import '../../core/models/station.dart';
import '../../core/providers/service_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../search/station_picker_page.dart';
import '../search/widgets/passenger_selector_sheet.dart';
import '../search/widgets/calendar_bottom_sheet.dart';
import '../booking/booking_page.dart';
import '../itinerary/itinerary_detail_page.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  int _segmentedControlGroupValue = 0;
  int _selectedCompanion = 0;

  // Station data
  Station? _fromStationData;
  Station? _toStationData;
  String _fromStation = '伦敦 St Pancras';
  String _toStation = '巴黎 Gare du Nord';
  String _fromUic = '7015400';
  String _toUic = '8727100';

  DateTime? _outboundDate = DateTime.now().add(const Duration(days: 3));
  DateTime? _returnDate;
  int _adults = 1;
  int _youths = 0;
  int _children = 0;

  // AI planner state
  String _aiCity = '';
  String _aiCountry = '';
  DateTime? _aiStartDate;
  int _aiDays = 3;
  bool _aiLoading = false;

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
      final tempUic = _fromUic;
      _fromUic = _toUic;
      _toUic = tempUic;
      final tempData = _fromStationData;
      _fromStationData = _toStationData;
      _toStationData = tempData;
    });
  }

  bool get _isFormValid {
    if (_fromStation == _toStation) return false;
    if (_outboundDate == null) return false;
    if (_returnDate != null && _returnDate!.isBefore(_outboundDate!)) return false;
    if ((_adults + _youths + _children) == 0) return false;
    return true;
  }

  void _searchTrains() {
    if (!_isFormValid) return;
    final dateStr =
        '${_outboundDate!.year}-${_outboundDate!.month.toString().padLeft(2, '0')}-${_outboundDate!.day.toString().padLeft(2, '0')}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(
          originUic: _fromUic,
          destinationUic: _toUic,
          originName: _fromStation,
          destinationName: _toStation,
          date: dateStr,
          adults: _adults,
          youth: _youths,
          children: _children,
        ),
      ),
    );
  }

  Future<void> _createAiItinerary() async {
    if (_aiCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入目的地城市')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _aiLoading = true);
    try {
      final startDate = _aiStartDate ?? DateTime.now().add(const Duration(days: 7));
      final dateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final itinerary = await ServiceProvider().itineraryService.create(
        city: _aiCity,
        startDate: dateStr,
        days: _aiDays,
        country: _aiCountry.isNotEmpty ? _aiCountry : null,
        companionType: _selectedCompanion,
      );
      if (mounted) {
        setState(() => _aiLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItineraryDetailPage(itineraryId: itinerary.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _aiLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建行程失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
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
                    context.colors.background,
                    context.colors.background.withOpacity(0.9),
                    context.colors.background.withOpacity(0.0),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlowFab(
                    label: _segmentedControlGroupValue == 0 
                        ? (_aiLoading ? '正在生成中...' : '智能生成专属行程')
                        : '搜索欧洲之星车次',
                    icon: _segmentedControlGroupValue == 0 
                        ? PhosphorIconsRegular.magicWand
                        : PhosphorIconsRegular.train,
                    onTap: () {
                      if (_segmentedControlGroupValue == 0) {
                        _createAiItinerary();
                      } else {
                        _searchTrains();
                      }
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
              GestureDetector(
                onTap: () => _showCityInputDialog(),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIconsRegular.paperPlaneRight,
                          color: context.colors.brandBlue, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('你想去哪儿？',
                              style: context.textStyles.bodySmall),
                          Text(_aiCity.isNotEmpty ? _aiCity : '点击选择目的地城市',
                              style: context.textStyles.h3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                child: SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    color: context.colors.borderLight,
                    thickness: 2,
                  ),
                ),
              ),
              // Dates
              GestureDetector(
                onTap: () async {
                  final picked = await showModalBottomSheet<DateTime>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CalendarBottomSheet(
                      initialDate: _aiStartDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      isOutbound: true,
                    ),
                  );
                  if (picked != null) setState(() => _aiStartDate = picked);
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIconsRegular.calendarBlank,
                          color: context.colors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('出发日期',
                              style: context.textStyles.bodySmall),
                          Text(
                            _aiStartDate != null
                                ? '${_aiStartDate!.month}月${_aiStartDate!.day}日 · $_aiDays 天'
                                : '选择出发日期',
                            style: context.textStyles.h3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Days selector
              Row(
                children: [
                  Text('旅行天数', style: context.textStyles.bodySmall),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.borderLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_aiDays > 1) setState(() => _aiDays--);
                          },
                          child: Container(
                            width: 32, height: 32,
                            alignment: Alignment.center,
                            child: Icon(PhosphorIconsBold.minus,
                                size: 14, color: context.colors.textMain),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('$_aiDays 天',
                              style: context.textStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_aiDays < 65) setState(() => _aiDays++);
                          },
                          child: Container(
                            width: 32, height: 32,
                            alignment: Alignment.center,
                            child: Icon(PhosphorIconsBold.plus,
                                size: 14, color: context.colors.textMain),
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
        const SizedBox(height: 24),

        // Companions
        Text('和谁一起', style: context.textStyles.h3),
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
            Text('热门路线灵感', style: context.textStyles.h3),
            Icon(PhosphorIconsRegular.arrowRight, size: 18, color: context.colors.textMuted),
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
                Container(
                  decoration: BoxDecoration(
                    color: _fromStation == _toStation ? Colors.red.withOpacity(0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStationField('出发地', _fromStation, PhosphorIconsFill.mapPin, true),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Divider(height: 24, color: context.colors.borderLight),
                      ),
                      _buildStationField('目的地', _toStation, PhosphorIconsFill.mapPinLine, false),
                    ],
                  ),
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
                        border: Border.all(color: context.colors.borderLight),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Icon(PhosphorIconsBold.arrowsDownUp, color: context.colors.brandBlue, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.borderLight),
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
                Container(width: 1, height: 40, color: context.colors.borderLight),
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
          Divider(height: 1, color: context.colors.borderLight),
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
          Divider(height: 1, color: context.colors.borderLight),
          // Recent Searches section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('最近搜索', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                    Icon(PhosphorIconsRegular.clockCounterClockwise, size: 14, color: context.colors.textMuted),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRecentSearchToken('伦敦', '巴黎', '10月1日'),
                    _buildRecentSearchToken('布鲁塞尔', '阿姆斯特丹', '12月15日'),
                  ],
                ),
              ],
            ),
          ),
          // Search CTA
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (_fromStation == _toStation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIconsFill.warningCircle, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                         Text('出发地和目的地不能相同', style: context.textStyles.caption.copyWith(color: Colors.orange)),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _searchTrains : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid ? context.colors.brandBlue : context.colors.borderLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('查找车票', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isFormValid ? Colors.white : context.colors.textMuted)),
                  ),
                ),
              ],
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
        if (result != null && result is Station) {
          setState(() {
            if (isFrom) {
              _fromStationData = result;
              _fromStation = result.city ?? result.name;
              _fromUic = result.uicCode;
            } else {
              _toStationData = result;
              _toStation = result.city ?? result.name;
              _toUic = result.uicCode;
            }
          });
        }
      },
      child: Row(
        children: [
          Icon(icon, color: context.colors.brandBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                const SizedBox(height: 4),
                Text(value, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
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
          Icon(icon, color: isPlaceholder ? context.colors.textMain : context.colors.brandBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textStyles.bodyMedium.copyWith(
                    fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.bold,
                    color: isPlaceholder ? context.colors.textMain : context.colors.textMain,
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
    
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Background provided by the widget
      builder: (_) => CalendarBottomSheet(
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        isOutbound: isOutbound,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isOutbound) {
          _outboundDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null; // Auto-clear return date if invalid
          }
        } else {
          // Double check to prevent inversion during selection
          if (_outboundDate != null && picked.isBefore(_outboundDate!)) {
            // Revert or show toast (for now just clamp it to outbound date)
            _returnDate = _outboundDate;
          } else {
            _returnDate = picked;
          }
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
      backgroundColor: context.colors.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&q=80&w=1000',
              fit: BoxFit.cover,
            ),
            // The Dark Gradient Mask
            Container(
              decoration: BoxDecoration(
                gradient: context.colors.heroGradient,
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
                    style: context.textStyles.h1.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FlipEarth 官方直连，极速出票。',
                    style: context.textStyles.bodyMedium.copyWith(
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
                  color: context.colors.brandBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.brandBlue.withOpacity(0.3),
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

  void _showCityInputDialog() {
    final cityCtrl = TextEditingController(text: _aiCity);
    final countryCtrl = TextEditingController(text: _aiCountry);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('目的地'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: '城市名称 (英文)',
                hintText: 'e.g. Paris, Rome, Barcelona',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countryCtrl,
              decoration: const InputDecoration(
                labelText: '国家 (可选)',
                hintText: 'e.g. France',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _aiCity = cityCtrl.text.trim();
                _aiCountry = countryCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchToken(String from, String to, String date) {
    return GestureDetector(
      onTap: () {
        // Mock apply recent search
        setState(() {
          _fromStation = from;
          _toStation = to;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.brandBlue.withOpacity(0.05),
          border: Border.all(color: context.colors.brandBlue.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(from, style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMain)),
            Icon(PhosphorIconsBold.arrowRight, size: 10, color: context.colors.textMuted),
            Text(to, style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMain)),
            Container(width: 1, height: 10, color: context.colors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 6)),
            Text(date, style: context.textStyles.caption.copyWith(color: context.colors.brandBlue)),
          ],
        ),
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
        color: isSelected ? Colors.white : context.colors.textSecondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : context.colors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(title),
        ],
      ),
    );
  }
}
