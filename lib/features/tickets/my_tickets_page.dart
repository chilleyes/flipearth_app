import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/widgets/shimmer_skeleton.dart';
import '../../core/widgets/empty_state_widget.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  bool _isLoading = true;
  final bool _hasTickets = true; // Set to true to test
  late ConfettiController _confettiController;
  bool _isStamped = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900 background
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  if (_isLoading) ...[
                    const TicketSkeletonCard(),
                  ] else if (!_hasTickets) ...[
                    const EmptyStateWidget(
                      title: '暂无行程车票',
                      subtitle: '您的下一段旅程，由 FlipEarth 开启。',
                      icon: PhosphorIconsRegular.ticket,
                    ),
                  ] else ...[
                    _buildTicketCard(),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: _buildConfettiOverlay(), // Floating at top for visual effect
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }

  Widget _buildConfettiOverlay() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirection: pi / 2, // straight down
      maxBlastForce: 40,
      minBlastForce: 10,
      emissionFrequency: 0.1,
      numberOfParticles: 30,
      gravity: 0.2,
      colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的车票',
            style: context.textStyles.h1.copyWith(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          Text(
            '1 张即将出行的欧洲之星车票',
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              // Upper half
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8FAFC)], // slate-50
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Eurostar fake logo
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Eurostar_logo_2023.svg/512px-Eurostar_logo_2023.svg.png',
                          height: 20,
                          color: context.colors.textMain, // mix-blend-multiply alternative
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5), // emerald-100
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)), // emerald-200
                          ),
                          child: Text(
                            '已出票',
                            style: context.textStyles.caption.copyWith(
                              color: const Color(0xFF047857), // emerald-700
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Route
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Departure
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LON',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.textMain,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'St Pancras Int.',
                                style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Divider and train icon
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '2h 16m',
                                style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: Colors.transparent, // Layout anchor
                                  ),
                                  // The Custom paint dashed line
                                  CustomPaint(
                                    size: const Size(double.infinity, 1),
                                    painter: _DashedLinePainter(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    color: const Color(0xFFF8FAFC),
                                    child: Icon(
                                      PhosphorIconsFill.train,
                                      color: context.colors.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'EST 9014',
                                style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.brandBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrival
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PAR',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.textMain,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gare du Nord',
                                style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textSecondary,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Middle cutout section (transparent via Clipper, so we just draw the dashed line here)
              SizedBox(
                height: 32,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CustomPaint(
                      size: const Size(double.infinity, 2),
                      painter: _DashedLinePainter(color: context.colors.borderLight, strokeWidth: 2),
                    ),
                  ),
                ),
              ),

              // Lower half
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.borderLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=FLIPEARTH-EST9014',
                        width: 110,
                        height: 110,
                      ),
                    ),
                    if (_isStamped)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        tween: Tween(begin: 2.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red.shade700, width: 3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'BOARDED / 已出行',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _isStamped = true);
                            _confettiController.play();
                          },
                          icon: const Icon(PhosphorIconsFill.stamp),
                          label: const Text('模拟检票打卡', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.brandBlue,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(PhosphorIconsFill.wallet, color: Colors.white, size: 24),
                        label: const Text(
                          '添加到 Apple Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 16.0;
    
    // The y position of the middle separator (rough estimate based on layout)
    // Upper section = 24 padding + 20 logo + 24 gap + 60 route text = ~128. Add padding = 152
    // Let's use an exact pixel value based on the fixed contents above it.
    const double cutoutY = 176.0;

    path.lineTo(0, cutoutY - radius);
    path.arcToPoint(
      const Offset(0, cutoutY + radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, cutoutY + radius);
    path.arcToPoint(
      Offset(size.width, cutoutY - radius),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({
    this.color = const Color(0xFFCBD5E1), // slate-300
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
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
