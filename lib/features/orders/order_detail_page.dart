import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(context),
              SliverToBoxAdapter(
                child: _buildDetailsContent(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)), // Padding for bottom buttons
            ],
          ),
          _buildBottomActionRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: context.colors.textMain, // slate-900 background
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Solid dark background
            Container(color: context.colors.textMain),
            // Bottom blue border equivalent
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(height: 2, color: context.colors.brandBlue),
            ),
            // Dot Grid overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(color: context.colors.brandBlue.withOpacity(0.2)),
              ),
            ),
            // Content
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EUROSTAR STANDARD',
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.brandBlue,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '伦敦到巴黎',
                        style: context.textStyles.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  // Inverted Eurostar Text (Simplified as Icon placeholder for now)
                  const Opacity(
                    opacity: 0.5,
                    child: Icon(PhosphorIconsFill.train, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassIconButton(icon: PhosphorIconsBold.arrowLeft, onTap: () => Navigator.pop(context)),
          _buildGlassIconButton(icon: PhosphorIconsBold.downloadSimple, onTap: () {}),
        ],
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

  Widget _buildDetailsContent() {
    return Transform.translate(
      offset: const Offset(0, -24), // -mt-6 equivalent
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Ticket Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.borderLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
                ],
              ),
              child: Column(
                children: [
                  // Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5), // emerald-100
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '已确认 (CONFIRMED)',
                          style: context.textStyles.caption.copyWith(
                            color: const Color(0xFF047857), // emerald-700
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        '订单号: #EST-9014-ABC',
                        style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Time & Route Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('09:31', style: context.textStyles.h1.copyWith(fontSize: 32, letterSpacing: -1.0)),
                          const SizedBox(height: 4),
                          Text('10月1日, St Pancras', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Text('2h 16m', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted, fontSize: 11)),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // Dashed Line
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomPaint(
                                      painter: _HorizontalDashedLinePainter(color: context.colors.borderLight),
                                    ),
                                  ),
                                  // Train Icon overlaid
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(PhosphorIconsFill.train, color: context.colors.brandBlue, size: 24),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('直达', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('12:47', style: context.textStyles.h1.copyWith(fontSize: 32, letterSpacing: -1.0)),
                          const SizedBox(height: 4),
                          Text('10月1日, Gare du Nord', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Coach & Seat Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COACH (车厢)', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Text('09', style: context.textStyles.h1.copyWith(fontSize: 24)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SEAT (座位)', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('45', style: context.textStyles.h1.copyWith(fontSize: 24)),
                                  const SizedBox(width: 4),
                                  Text('Window', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tip Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.brandBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.brandBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: context.colors.brandBlue.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(PhosphorIconsFill.info, color: context.colors.brandBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('乘车提示', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                '请提前至少 60 分钟抵达车站，以便完成安检和海关过境手续。列车在出发前 15 分钟停止检票。',
                                style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text('乘客信息', style: context.textStyles.h3.copyWith(fontSize: 18)),
            ),
            // Passenger & Price Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.borderLight),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ZHAO / HANG', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('成人 (Adult) · 护照 E1234****', style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: context.colors.background, shape: BoxShape.circle),
                        child: Icon(PhosphorIconsBold.pencilSimple, color: context.colors.textMuted, size: 18),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: context.colors.background, thickness: 1, height: 1),
                  ),
                  _buildPriceRow('票价 (Base Fare)', '€ 145.00'),
                  const SizedBox(height: 8),
                  _buildPriceRow('税费 (Taxes & Fees)', '€ 12.50'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: context.colors.borderLight, thickness: 1, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('总计 (Total)', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, fontSize: 15)),
                      Text('€ 157.50', style: context.textStyles.h2.copyWith(color: context.colors.brandBlue, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.w500, fontSize: 13)),
        Text(value, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomActionRow(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
        decoration: BoxDecoration(
          color: context.colors.background.withOpacity(0.9),
          border: Border(top: BorderSide(color: context.colors.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: context.colors.textSecondary,
                  elevation: 0,
                  side: BorderSide(color: context.colors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.arrowUDownLeft, size: 18),
                    const SizedBox(width: 6),
                    Text('退改签政策', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.textMain,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.headset, size: 18),
                    const SizedBox(width: 6),
                    Text('联系客服', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for the background dot grid
class _DotGridPainter extends CustomPainter {
  final Color color;

  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for horizontal dashed line
class _HorizontalDashedLinePainter extends CustomPainter {
  final Color color;

  _HorizontalDashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
