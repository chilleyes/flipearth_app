import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'station_picker_page.dart';
import 'widgets/passenger_selector_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280,
      backgroundColor: AppColors.brandBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              'https://images.unsplash.com/photo-1541355444983-5034c562dc62?auto=format&fit=crop&q=80&w=800', // Train / Europe aesthetic
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandBlue.withOpacity(0.6),
                    AppColors.brandBlue.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('开启下一段旅程', style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('预订欧洲之星及整个欧洲的火车票', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            const SizedBox(height: 32),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
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

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近搜索', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildRecentCard('伦敦', '巴黎', '10月24日'),
              const SizedBox(width: 12),
              _buildRecentCard('巴黎', '阿姆斯特丹', '11月1日'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard(String from, String to, String date) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(from, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 1)),
              const Icon(PhosphorIconsBold.arrowRight, size: 14, color: AppColors.textMuted),
              Expanded(child: Text(to, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 1, textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 8),
          Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
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
}
