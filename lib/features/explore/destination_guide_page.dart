import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../planner/planner_page.dart';

class DestinationGuidePage extends StatefulWidget {
  final String heroTag;
  final String title;
  final String subtitle;
  final String country;
  final String imageUrl;

  const DestinationGuidePage({
    super.key,
    required this.heroTag,
    required this.title,
    required this.subtitle,
    required this.country,
    required this.imageUrl,
  });

  @override
  State<DestinationGuidePage> createState() => _DestinationGuidePageState();
}

class _DestinationGuidePageState extends State<DestinationGuidePage> {
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    try {
      final imageProvider = NetworkImage(widget.imageUrl);
      final colorScheme = await ColorScheme.fromImageProvider(provider: imageProvider);
      if (mounted) {
        setState(() {
          _dominantColor = colorScheme.primary;
        });
      }
    } catch (e) {
      // Ignore errors if image loading fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildBody(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 350,
      backgroundColor: context.colors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsBold.caretLeft, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    context.colors.background.withOpacity(1.0),
                    _dominantColor?.withOpacity(0.4) ?? Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       border: Border.all(color: Colors.white.withOpacity(0.3)),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       widget.country,
                       style: context.textStyles.caption.copyWith(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                         letterSpacing: 1.0,
                       ),
                     ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: context.textStyles.h1.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('目的地概览', style: context.textStyles.h3),
          const SizedBox(height: 16),
          Text(
            '这是一段自动生成的目的地描述代码占位。这片土地以其悠久的历史、绝美的自然风光和充满活力的人文气息吸引着世界各地的旅行者。无论是在古老的街道漫步，还是在壮丽的山川之间驻足，这里都将为您带来不可磨灭的独家记忆。',
            style: context.textStyles.bodyMedium.copyWith(height: 1.6, color: context.colors.textMain.withOpacity(0.8)),
          ),
          const SizedBox(height: 32),
          Text('必去坐标', style: context.textStyles.h3),
          const SizedBox(height: 16),
          _buildSpotCard(context, '风景名胜 1', '绝对不能错过的打卡地标'),
          const SizedBox(height: 12),
          _buildSpotCard(context, '特色餐厅 2', '品味地道当地美食'),
          const SizedBox(height: 12),
          _buildSpotCard(context, '隐藏秘境 3', '远离喧嚣的小众宝藏景点'),
        ],
      ),
    );
  }

  Widget _buildSpotCard(BuildContext context, String name, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: context.colors.brandBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(PhosphorIconsFill.mapPin, color: context.colors.brandBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final fabBgColor = _dominantColor ?? context.colors.brandBlue;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: fabBgColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: fabBgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: () {
          // Navigate to Planner Page to plan this trip
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerPage()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(PhosphorIconsBold.magicWand, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('以此为灵感定制行程', style: context.textStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
