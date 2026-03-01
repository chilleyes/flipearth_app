import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/station.dart';
import '../../core/widgets/spring_button.dart';
import '../booking/booking_page.dart';
import 'station_picker_page.dart';
import 'widgets/calendar_bottom_sheet.dart';
import 'widgets/passenger_selector_sheet.dart';

class TrainSearchPage extends StatefulWidget {
  const TrainSearchPage({super.key});

  @override
  State<TrainSearchPage> createState() => _TrainSearchPageState();
}

class _TrainSearchPageState extends State<TrainSearchPage> {
  String _originCity = 'London';
  String _originUic = '7015400';
  String _destCity = 'Paris';
  String _destUic = '8727100';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  int _adults = 1;
  int _youths = 0;
  int _children = 0;

  int get _totalPassengers => _adults + _youths + _children;

  bool get _canSearch =>
      _originUic.isNotEmpty &&
      _destUic.isNotEmpty &&
      _originUic != _destUic;

  void _pickStation({required bool isOrigin}) async {
    final result = await Navigator.push<Station>(
      context,
      MaterialPageRoute(
        builder: (_) => const StationPickerPage(),
        fullscreenDialog: true,
      ),
    );
    if (result == null || !mounted) return;

    final city = result.city ?? result.name;
    final uic = result.uicCode;

    if (isOrigin && uic == _destUic) return;
    if (!isOrigin && uic == _originUic) return;

    setState(() {
      if (isOrigin) {
        _originCity = city;
        _originUic = uic;
      } else {
        _destCity = city;
        _destUic = uic;
      }
    });
  }

  void _swapStations() {
    HapticFeedback.lightImpact();
    setState(() {
      final tmpCity = _originCity;
      final tmpUic = _originUic;
      _originCity = _destCity;
      _originUic = _destUic;
      _destCity = tmpCity;
      _destUic = tmpUic;
    });
  }

  void _pickDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarBottomSheet(
        initialDate: _date,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        isOutbound: true,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  void _pickPassengers() async {
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
    if (result != null && mounted) {
      setState(() {
        _adults = result['adults'] ?? 1;
        _youths = result['youths'] ?? 0;
        _children = result['children'] ?? 0;
      });
    }
  }

  void _doSearch() {
    if (!_canSearch) return;
    HapticFeedback.mediumImpact();

    final dateStr =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(
          originUic: _originUic,
          destinationUic: _destUic,
          originName: _originCity,
          destinationName: _destCity,
          date: dateStr,
          adults: _adults,
          youth: _youths,
          children: _children,
        ),
      ),
    );
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
          _buildHeader(colors, textStyles),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteCard(colors, textStyles),
                  const SizedBox(height: 16),
                  _buildDateCard(colors, textStyles),
                  const SizedBox(height: 16),
                  _buildPassengerCard(colors, textStyles),
                  const SizedBox(height: 36),
                  _buildSearchButton(colors, textStyles),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          bottom: 28,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0C1B2A),
              colors.textMain.withOpacity(0.9),
              colors.background,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsBold.arrowLeft,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Train Search',
              style: textStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '搜索欧洲之星 · Eurostar & 欧铁车票',
              style: textStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Route Card ---

  Widget _buildRouteCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
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
      child: Column(
        children: [
          _buildStationRow(
            colors: colors,
            textStyles: textStyles,
            label: '出发',
            city: _originCity,
            icon: PhosphorIconsFill.navigationArrow,
            iconColor: colors.textMain,
            onTap: () => _pickStation(isOrigin: true),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Divider(height: 1, color: colors.borderLight),
                ),
                GestureDetector(
                  onTap: _swapStations,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.borderLight),
                    ),
                    child: Icon(PhosphorIconsBold.arrowsDownUp,
                        size: 16, color: colors.brandBlue),
                  ),
                ),
                Expanded(
                  child: Divider(height: 1, color: colors.borderLight),
                ),
              ],
            ),
          ),

          _buildStationRow(
            colors: colors,
            textStyles: textStyles,
            label: '到达',
            city: _destCity,
            icon: PhosphorIconsFill.mapPin,
            iconColor: colors.brandBlue,
            onTap: () => _pickStation(isOrigin: false),
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow({
    required AppColorsExtension colors,
    required AppTextStylesExtension textStyles,
    required String label,
    required String city,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return SpringButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textStyles.caption.copyWith(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    city,
                    style: textStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight,
                size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  // --- Date Card ---

  Widget _buildDateCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final dateFormat = DateFormat('yyyy年M月d日 · EEEE', 'zh_CN');
    String formattedDate;
    try {
      formattedDate = dateFormat.format(_date);
    } catch (_) {
      formattedDate =
          '${_date.year}年${_date.month}月${_date.day}日';
    }

    return SpringButton(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.purpleGlow.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIconsFill.calendarBlank,
                  color: colors.purpleGlow, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '出发日期',
                    style: textStyles.caption.copyWith(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedDate,
                    style: textStyles.h3.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight,
                size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  // --- Passenger Card ---

  Widget _buildPassengerCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final parts = <String>[];
    if (_adults > 0) parts.add('成人 $_adults');
    if (_youths > 0) parts.add('青年 $_youths');
    if (_children > 0) parts.add('儿童 $_children');
    final summary = parts.join(' · ');

    return SpringButton(
      onTap: _pickPassengers,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.successGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIconsFill.users,
                  color: colors.successGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '乘客',
                    style: textStyles.caption.copyWith(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$_totalPassengers 位 · $summary',
                    style: textStyles.h3.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight,
                size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  // --- Search Button ---

  Widget _buildSearchButton(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SpringButton(
      onTap: _canSearch ? _doSearch : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        decoration: BoxDecoration(
          gradient: _canSearch
              ? LinearGradient(colors: [colors.brandBlue, colors.purpleGlow])
              : null,
          color: _canSearch ? null : colors.borderLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _canSearch
              ? [
                  BoxShadow(
                    color: colors.brandBlue.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsBold.magnifyingGlass,
                color: _canSearch ? Colors.white : colors.textMuted,
                size: 20),
            const SizedBox(width: 10),
            Text(
              '搜索车票',
              style: textStyles.bodyLarge.copyWith(
                color: _canSearch ? Colors.white : colors.textMuted,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
