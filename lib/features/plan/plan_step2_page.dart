import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/plan.dart';
import '../../core/providers/service_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/glow_tag.dart';
import 'plan_loading_page.dart';

class PlanStep2Page extends StatefulWidget {
  final String departureCity;
  final String? departureStationUic;
  final DateTime startDate;
  final int days;
  final int passengers;

  const PlanStep2Page({
    super.key,
    required this.departureCity,
    required this.departureStationUic,
    required this.startDate,
    required this.days,
    required this.passengers,
  });

  @override
  State<PlanStep2Page> createState() => _PlanStep2PageState();
}

class _PlanStep2PageState extends State<PlanStep2Page> {
  int _budgetIndex = 1;
  int _paceIndex = 1;
  bool _needVisa = true;

  final _budgetOptions = [
    ('cheapest', 'Cheapest', PhosphorIconsRegular.piggyBank, '能省就省'),
    ('balanced', 'Balanced', PhosphorIconsRegular.scales, '性价比最佳'),
    ('comfortable', 'Comfortable', PhosphorIconsRegular.sparkle, '舒适优先'),
  ];

  final _paceOptions = [
    ('compact', 'Compact', PhosphorIconsRegular.lightning, '高效紧凑'),
    ('relaxed', 'Relaxed', PhosphorIconsRegular.coffee, '悠闲自在'),
  ];

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
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildStepIndicator(colors, 2),
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
                      'Your travel\npreferences',
                      style: textStyles.h1.copyWith(fontSize: 32, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '选择偏好，AI 将量身定制三套方案',
                      style: textStyles.bodyMedium.copyWith(color: colors.textMuted),
                    ),
                    const SizedBox(height: 36),

                    _buildSectionLabel(textStyles, 'BUDGET · 预算偏好'),
                    const SizedBox(height: 14),
                    _buildBudgetSelector(colors, textStyles),
                    const SizedBox(height: 32),

                    _buildSectionLabel(textStyles, 'PACE · 旅行节奏'),
                    const SizedBox(height: 14),
                    _buildPaceSelector(colors, textStyles),
                    const SizedBox(height: 32),

                    _buildVisaToggle(colors, textStyles),
                    const SizedBox(height: 32),

                    _buildSummaryCard(colors, textStyles),
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
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildBudgetSelector(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Row(
      children: List.generate(_budgetOptions.length, (i) {
        final (_, label, icon, desc) = _budgetOptions[i];
        final isSelected = _budgetIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == _budgetOptions.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _budgetIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected ? colors.brandBlue.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? colors.brandBlue : colors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 26, color: isSelected ? colors.brandBlue : colors.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? colors.brandBlue : colors.textMain,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: textStyles.caption.copyWith(fontSize: 10, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaceSelector(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Row(
      children: List.generate(_paceOptions.length, (i) {
        final (_, label, icon, desc) = _paceOptions[i];
        final isSelected = _paceIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == _paceOptions.length - 1 ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _paceIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colors.brandBlue.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? colors.brandBlue : colors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: isSelected ? colors.brandBlue : colors.textMuted),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected ? colors.brandBlue : colors.textMain,
                          ),
                        ),
                        Text(
                          desc,
                          style: textStyles.caption.copyWith(fontSize: 10, color: colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVisaToggle(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderLight),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.fileText(PhosphorIconsStyle.fill),
              color: colors.purpleGlow, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('需要签证行程单', style: textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('自动生成申根签所需材料', style: textStyles.caption.copyWith(color: colors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _needVisa,
            onChanged: (v) => setState(() => _needVisa = v),
            activeColor: colors.brandBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final dateStr =
        '${widget.startDate.year}/${widget.startDate.month}/${widget.startDate.day}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.brandBlue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.brandBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('行程概要', style: textStyles.caption.copyWith(
            color: colors.brandBlue, fontWeight: FontWeight.w900, letterSpacing: 0.5,
          )),
          const SizedBox(height: 10),
          _buildSummaryRow(textStyles, colors, '出发城市', widget.departureCity),
          _buildSummaryRow(textStyles, colors, '出发日期', dateStr),
          _buildSummaryRow(textStyles, colors, '旅行天数', '${widget.days} 天'),
          _buildSummaryRow(textStyles, colors, '旅行人数', '${widget.passengers} 人'),
          _buildSummaryRow(textStyles, colors, '预算偏好', _budgetOptions[_budgetIndex].$2),
          _buildSummaryRow(textStyles, colors, '旅行节奏', _paceOptions[_paceIndex].$2),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AppTextStylesExtension textStyles, AppColorsExtension colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyles.bodySmall.copyWith(color: colors.textMuted)),
          Text(value, style: textStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: colors.textMain)),
        ],
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
          onPressed: _onGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.magicWand(PhosphorIconsStyle.fill),
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Generate My Plan',
                style: textStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGenerate() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final input = PlanInput(
      departureCity: widget.departureCity,
      departureStationUic: widget.departureStationUic,
      startDate: widget.startDate,
      days: widget.days,
      passengers: widget.passengers,
      budgetLevel: _budgetOptions[_budgetIndex].$1,
      pace: _paceOptions[_paceIndex].$1,
      needVisaItinerary: _needVisa,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlanLoadingPage(input: input),
      ),
    );
  }
}
