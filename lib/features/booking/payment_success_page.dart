import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:confetti/confetti.dart';
import '../../core/models/booking_context.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? bookingReference;
  final double? amount;
  final String? currency;
  final BookingContext? bookingContext;

  const PaymentSuccessPage({
    super.key,
    this.bookingReference,
    this.amount,
    this.currency,
    this.bookingContext,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;

  bool get _isFromTrip =>
      widget.bookingContext != null && widget.bookingContext!.entrySource == 'trip';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _controller.forward().then((_) {
      HapticFeedback.lightImpact();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPrimaryAction() {
    if (_isFromTrip) {
      Navigator.popUntil(context, (route) {
        return route.isFirst || route.settings.name == '/trip_detail';
      });
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _onSecondaryAction() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  _buildSuccessAnimation(colors),
                  const SizedBox(height: 48),
                  _buildTextContent(colors, textStyles),
                  const Spacer(),
                  _buildActions(colors, textStyles),
                ],
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                colors.brandBlue,
                colors.successGreen,
                colors.purpleGlow,
                const Color(0xFFFBBF24),
                const Color(0xFFF472B6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation(AppColorsExtension colors) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 160,
            height: 160,
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json',
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.successGreen.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(PhosphorIconsBold.check, color: Color(0xFF047857), size: 64),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Column(
        children: [
          Text('支付成功！', style: textStyles.h1.copyWith(fontSize: 32, letterSpacing: -1.0)),
          const SizedBox(height: 12),
          Text(
            _isFromTrip ? '车票已购买并添加到您的行程中' : '您的欧洲之星车票已出票成功',
            style: textStyles.bodyMedium.copyWith(color: colors.textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildOrderSummaryCard(colors, textStyles),
          if (_isFromTrip) ...[
            const SizedBox(height: 16),
            _buildTripContextBanner(colors, textStyles),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('订单编号', style: textStyles.bodyMedium.copyWith(color: colors.textMuted)),
              Text(widget.bookingReference ?? 'N/A', style: textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 24, color: colors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('实付金额', style: textStyles.bodyMedium.copyWith(color: colors.textMuted)),
              Text(
                widget.amount != null ? '€ ${widget.amount!.toStringAsFixed(2)}' : 'N/A',
                style: textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: colors.brandBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripContextBanner(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.brandBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.brandBlue.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.suitcase(PhosphorIconsStyle.fill), size: 20, color: colors.brandBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '此车票已自动关联到您的行程计划',
              style: textStyles.bodySmall.copyWith(color: colors.brandBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isFromTrip)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(PhosphorIconsBold.arrowLeft, color: Colors.white, size: 20),
                    ),
                  Text(
                    _isFromTrip ? '返回行程画布' : '查看我的车票',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: _onSecondaryAction,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                '返回首页',
                style: textStyles.bodyMedium.copyWith(color: colors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
