import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../payment_success_page.dart';

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({super.key});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  bool _isProcessing = false;

  void _handlePayment() async {
    HapticFeedback.heavyImpact(); // Strong haptic on pay
    setState(() {
      _isProcessing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // Close sheet
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('确认付款', style: context.textStyles.h2.copyWith(fontSize: 22)),
                  const SizedBox(height: 24),
                  
                  // Price Breakdown
                  _buildPriceRow('伦敦 到 巴黎', '€ 45.00'),
                  const SizedBox(height: 12),
                  _buildPriceRow('服务费', '€ 2.00'),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: context.colors.borderLight),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('总计', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text('€ 47.00', style: context.textStyles.h2.copyWith(fontSize: 24, color: context.colors.textMain)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Payment Methods
                  Text('选择支付方式', style: context.textStyles.h3),
                  const SizedBox(height: 16),
                  
                  // Mock Apple Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isProcessing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIconsFill.appleLogo, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text('Pay', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Credit Card Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.colors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsRegular.creditCard, color: context.colors.textMain, size: 20),
                          const SizedBox(width: 8),
                          Text('信用卡 / 借记卡', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted)),
        Text(amount, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
