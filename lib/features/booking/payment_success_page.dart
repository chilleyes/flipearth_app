import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../tickets/my_tickets_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? bookingReference;
  final double? amount;
  final String? currency;

  const PaymentSuccessPage({
    super.key,
    this.bookingReference,
    this.amount,
    this.currency,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _controller.forward().then((_) {
      HapticFeedback.lightImpact(); // Secondary feedback when text fades in
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
       HapticFeedback.mediumImpact(); // Primary feedback on badge pop
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Success Animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5), // emerald-100
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                        ],
                      ),
                      child: const Center(
                        child: Icon(PhosphorIconsBold.check, color: Color(0xFF047857), size: 64), // emerald-700
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // Text Content
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    Text('支付成功！', style: context.textStyles.h1.copyWith(fontSize: 32, letterSpacing: -1.0)),
                    const SizedBox(height: 12),
                    Text(
                      '您的欧洲之星车票已出票成功',
                      style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Order Mini Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('订单编号', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted)),
                              Text(widget.bookingReference ?? 'N/A', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Divider(height: 24, color: context.colors.borderLight),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('实付金额', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted)),
                              Text(
                                widget.amount != null ? '€ ${widget.amount!.toStringAsFixed(2)}' : 'N/A',
                                style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.colors.brandBlue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Bottom Actions
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Jump to my tickets
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyTicketsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.brandBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('查看我的车票', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: () {
                          // Pop to root (MainLayout)
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('返回首页', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.bold)),
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
