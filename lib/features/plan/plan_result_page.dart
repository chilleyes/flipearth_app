import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/plan.dart';
import '../../core/providers/service_provider.dart';
import '../../core/widgets/spring_button.dart';
import '../trips/trip_detail_page.dart';

class PlanResultPage extends StatefulWidget {
  final PlanResult plan;

  const PlanResultPage({super.key, required this.plan});

  @override
  State<PlanResultPage> createState() => _PlanResultPageState();
}

class _PlanResultPageState extends State<PlanResultPage> {
  final _planService = ServiceProvider().planService;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  bool _isSelecting = false;

  static const _optionColors = [
    Color(0xFF10B981), // Cheapest - green
    Color(0xFF0EA5E9), // Recommended - blue
    Color(0xFFA855F7), // Comfortable - purple
  ];

  static const _optionIcons = [
    PhosphorIconsFill.piggyBank,
    PhosphorIconsFill.star,
    PhosphorIconsFill.sparkle,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final options = widget.plan.options;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: colors.textMain),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: _buildStepIndicator(colors, 3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your plans\nare ready!',
                    style: textStyles.h1.copyWith(fontSize: 32, height: 1.1),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'AI 为你生成了 ${options.length} 套方案，左右滑动查看',
                    style: textStyles.bodyMedium.copyWith(color: colors.textMuted),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: options.isEmpty
                  ? _buildEmptyState(colors, textStyles)
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionCard(
                          context,
                          options[index],
                          index,
                          colors,
                          textStyles,
                        );
                      },
                    ),
            ),
            if (options.isNotEmpty) ...[
              _buildPageDots(colors, options.length),
              const SizedBox(height: 16),
              _buildSelectButton(colors, textStyles, options),
              const SizedBox(height: 24),
            ],
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

  Widget _buildOptionCard(
    BuildContext context,
    PlanOption option,
    int index,
    AppColorsExtension colors,
    AppTextStylesExtension textStyles,
  ) {
    final color = _optionColors[index % _optionColors.length];
    final icon = _optionIcons[index % _optionIcons.length];
    final isRecommended = index == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isRecommended ? color.withOpacity(0.4) : colors.borderLight,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isRecommended ? 0.12 : 0.06),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsFill.star, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'RECOMMENDED',
                      style: textStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, size: 24, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.labelText,
                                style: textStyles.h3.copyWith(fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${option.totalDays} days',
                                style: textStyles.caption.copyWith(color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '${_currencySymbol(option.currency)}${option.estimatedTotalPrice.toStringAsFixed(0)}',
                      style: textStyles.h1.copyWith(
                        fontSize: 44,
                        color: color,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      '预估总价 · per person',
                      style: textStyles.caption.copyWith(color: colors.textMuted),
                    ),
                    const Spacer(),
                    if (option.reason != null && option.reason!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(PhosphorIcons.lightbulb(PhosphorIconsStyle.fill),
                                size: 16, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option.reason!,
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (option.riskLevel != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _riskColor(option.riskLevel!),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Risk: ${option.riskLevel}',
                            style: textStyles.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: 200 + index * 150));
  }

  Widget _buildPageDots(AppColorsExtension colors, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? colors.brandBlue : colors.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSelectButton(
    AppColorsExtension colors,
    AppTextStylesExtension textStyles,
    List<PlanOption> options,
  ) {
    final currentOption = options[_currentPage];
    final color = _optionColors[_currentPage % _optionColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSelecting ? null : () => _selectOption(currentOption),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            shadowColor: color.withOpacity(0.4),
          ),
          child: _isSelecting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsFill.checkCircle, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Choose "${currentOption.labelText}"',
                      style: textStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warning(), size: 48, color: colors.textMuted),
          const SizedBox(height: 16),
          Text('未生成任何方案', style: textStyles.h3),
          const SizedBox(height: 8),
          Text('请返回重新尝试', style: textStyles.bodySmall.copyWith(color: colors.textMuted)),
        ],
      ),
    );
  }

  Future<void> _selectOption(PlanOption option) async {
    HapticFeedback.mediumImpact();
    setState(() => _isSelecting = true);

    try {
      final tripId = await _planService.selectPlanOption(widget.plan.id, option.id);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TripDetailPage(tripId: tripId)),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSelecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择方案失败: $e')),
        );
      }
    }
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
}
