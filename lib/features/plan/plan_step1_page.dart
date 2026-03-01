import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/spring_button.dart';
import '../search/station_picker_page.dart';
import '../search/widgets/calendar_bottom_sheet.dart';
import 'plan_step2_page.dart';

class PlanStep1Page extends StatefulWidget {
  final bool showBackButton;

  const PlanStep1Page({super.key, this.showBackButton = true});

  @override
  State<PlanStep1Page> createState() => _PlanStep1PageState();
}

class _PlanStep1PageState extends State<PlanStep1Page> {
  String _departureCity = '';
  String? _departureStationUic;
  DateTime? _startDate;
  int _days = 5;
  int _passengers = 1;

  bool get _canProceed => _departureCity.isNotEmpty && _startDate != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(PhosphorIcons.arrowLeft(), color: colors.textMain),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: _buildStepIndicator(colors, 1),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where are you\nstarting from?',
                      style: textStyles.h1.copyWith(fontSize: 32, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '告诉我们出发信息，AI 将为你规划最佳路线',
                      style: textStyles.bodyMedium.copyWith(color: colors.textMuted),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionLabel(textStyles, '出发城市'),
                    const SizedBox(height: 10),
                    _buildDepartureCityField(colors, textStyles),
                    const SizedBox(height: 28),

                    _buildSectionLabel(textStyles, '出发日期'),
                    const SizedBox(height: 10),
                    _buildDateField(colors, textStyles),
                    const SizedBox(height: 28),

                    _buildSectionLabel(textStyles, '旅行天数'),
                    const SizedBox(height: 10),
                    _buildDaysSelector(colors, textStyles),
                    const SizedBox(height: 28),

                    _buildSectionLabel(textStyles, '旅行人数'),
                    const SizedBox(height: 10),
                    _buildPassengerSelector(colors, textStyles),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomAction(colors, textStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(AppColorsExtension colors, int step) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i < step;
        final isCurrent = i == step - 1;
        return Container(
          width: isCurrent ? 32 : 12,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? colors.brandBlue : colors.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildSectionLabel(AppTextStylesExtension textStyles, String label) {
    return Text(
      label,
      style: textStyles.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDepartureCityField(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return GestureDetector(
      onTap: _showCityPicker,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _departureCity.isNotEmpty
                ? colors.brandBlue.withOpacity(0.3)
                : colors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.brandBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  color: colors.brandBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _departureCity.isNotEmpty ? _departureCity : '选择出发城市 / 车站',
                style: _departureCity.isNotEmpty
                    ? textStyles.h3.copyWith(fontSize: 18)
                    : textStyles.bodyMedium.copyWith(color: colors.textMuted),
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<DateTime>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CalendarBottomSheet(
            initialDate: _startDate ?? DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            isOutbound: true,
          ),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _startDate != null
                ? colors.brandBlue.withOpacity(0.3)
                : colors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.brandBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                  color: colors.brandBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _startDate != null
                    ? '${_startDate!.year}年${_startDate!.month}月${_startDate!.day}日'
                    : '选择出发日期',
                style: _startDate != null
                    ? textStyles.h3.copyWith(fontSize: 18)
                    : textStyles.bodyMedium.copyWith(color: colors.textMuted),
              ),
            ),
            Icon(PhosphorIcons.caretRight(), size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelector(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            child: Icon(PhosphorIcons.sun(PhosphorIconsStyle.fill),
                color: colors.purpleGlow, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('$_days 天', style: textStyles.h3.copyWith(fontSize: 18)),
          ),
          _buildCounterButton(
            icon: PhosphorIcons.minus(),
            onTap: () {
              if (_days > 1) setState(() => _days--);
            },
            colors: colors,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$_days', style: textStyles.h2.copyWith(fontSize: 20)),
          ),
          _buildCounterButton(
            icon: PhosphorIcons.plus(),
            onTap: () {
              if (_days < 65) setState(() => _days++);
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerSelector(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              color: colors.successGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(PhosphorIcons.users(PhosphorIconsStyle.fill),
                color: colors.successGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('$_passengers 人', style: textStyles.h3.copyWith(fontSize: 18)),
          ),
          _buildCounterButton(
            icon: PhosphorIcons.minus(),
            onTap: () {
              if (_passengers > 1) setState(() => _passengers--);
            },
            colors: colors,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$_passengers', style: textStyles.h2.copyWith(fontSize: 20)),
          ),
          _buildCounterButton(
            icon: PhosphorIcons.plus(),
            onTap: () {
              if (_passengers < 9) setState(() => _passengers++);
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColorsExtension colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.borderLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: colors.textMain),
      ),
    );
  }

  Widget _buildBottomAction(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.borderLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canProceed
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanStep2Page(
                        departureCity: _departureCity,
                        departureStationUic: _departureStationUic,
                        startDate: _startDate!,
                        days: _days,
                        passengers: _passengers,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canProceed ? colors.brandBlue : colors.borderLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: _canProceed ? 4 : 0,
            shadowColor: colors.brandBlue.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: textStyles.bodyLarge.copyWith(
                  color: _canProceed ? Colors.white : colors.textMuted,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                PhosphorIcons.arrowRight(),
                size: 20,
                color: _canProceed ? Colors.white : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StationPickerPage(),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      setState(() {
        _departureCity = result.city ?? result.name;
        _departureStationUic = result.uicCode;
      });
    }
  }
}
