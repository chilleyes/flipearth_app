import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/plan.dart';
import '../../core/providers/service_provider.dart';
import '../../core/widgets/shimmer_skeleton.dart';
import 'plan_result_page.dart';

class PlanLoadingPage extends StatefulWidget {
  final PlanInput input;

  const PlanLoadingPage({super.key, required this.input});

  @override
  State<PlanLoadingPage> createState() => _PlanLoadingPageState();
}

class _PlanLoadingPageState extends State<PlanLoadingPage> with SingleTickerProviderStateMixin {
  final _planService = ServiceProvider().planService;
  late AnimationController _dotController;
  String? _error;
  int _tipIndex = 0;

  final _tips = [
    '正在分析最佳路线...',
    '比较不同价位的车次...',
    '计算最优换乘方案...',
    '生成签证行程单模板...',
    '即将完成，请稍候...',
  ];

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _startTipRotation();
    _createPlan();
  }

  void _startTipRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
      return mounted;
    });
  }

  Future<void> _createPlan() async {
    try {
      final result = await _planService.createPlan(widget.input.toJson());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PlanResultPage(plan: result)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _error != null
            ? _buildErrorView(colors, textStyles)
            : _buildLoadingView(colors, textStyles),
      ),
    );
  }

  Widget _buildLoadingView(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.brandBlue, colors.purpleGlow],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.brandBlue.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(PhosphorIconsFill.magicWand, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AI is crafting\nyour perfect trip',
            style: textStyles.h2.copyWith(fontSize: 26, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _tips[_tipIndex],
              key: ValueKey(_tipIndex),
              style: textStyles.bodyMedium.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          _buildSkeletonCards(colors),
          const Spacer(flex: 3),
          AnimatedBuilder(
            animation: _dotController,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final offset = (_dotController.value * 3 - i).clamp(0.0, 1.0);
                  final scale = 0.6 + 0.4 * (1.0 - (offset - 0.5).abs() * 2).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: colors.brandBlue.withOpacity(0.3 + 0.7 * scale),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSkeletonCards(AppColorsExtension colors) {
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: i == 0 ? 0 : 6,
              right: i == 2 ? 0 : 6,
            ),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerSkeleton(width: 60, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                ShimmerSkeleton(width: 40, height: 24, borderRadius: 6),
                const SizedBox(height: 8),
                ShimmerSkeleton(width: 70, height: 10, borderRadius: 4),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorView(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.warning(), size: 56, color: colors.textMuted),
            const SizedBox(height: 20),
            Text('方案生成失败', style: textStyles.h3),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: textStyles.bodySmall.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                setState(() => _error = null);
                _createPlan();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('重试', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('返回修改', style: textStyles.bodyMedium.copyWith(color: colors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
