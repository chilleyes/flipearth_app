import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PassengerSelectorSheet extends StatefulWidget {
  final int initialAdults;
  final int initialYouths;
  final int initialChildren;

  const PassengerSelectorSheet({
    super.key,
    this.initialAdults = 1,
    this.initialYouths = 0,
    this.initialChildren = 0,
  });

  @override
  State<PassengerSelectorSheet> createState() => _PassengerSelectorSheetState();
}

class _PassengerSelectorSheetState extends State<PassengerSelectorSheet> {
  late int _adults;
  late int _youths;
  late int _children;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _youths = widget.initialYouths;
    _children = widget.initialChildren;
  }

  void _confirm() {
    Navigator.pop(context, {
      'adults': _adults,
      'youths': _youths,
      'children': _children,
    });
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
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('选择乘客', style: AppTextStyles.h2.copyWith(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildCounterRow(
                    title: '成人',
                    subtitle: '26 - 59 岁',
                    value: _adults,
                    onChanged: (v) => setState(() => _adults = v),
                    min: 1,
                  ),
                  const Divider(height: 32, color: AppColors.borderLight),
                  _buildCounterRow(
                    title: '青年',
                    subtitle: '12 - 25 岁',
                    value: _youths,
                    onChanged: (v) => setState(() => _youths = v),
                  ),
                  const Divider(height: 32, color: AppColors.borderLight),
                  _buildCounterRow(
                    title: '儿童',
                    subtitle: '4 - 11 岁',
                    value: _children,
                    onChanged: (v) => setState(() => _children = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textMain,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('确认', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
    int min = 0,
    int max = 9,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: value > min ? () => onChanged(value - 1) : null,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: value > min ? Colors.white : AppColors.background,
                  border: Border.all(color: value > min ? AppColors.borderLight : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIconsBold.minus, size: 16, color: value > min ? AppColors.textMain : AppColors.textMuted),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            GestureDetector(
              onTap: value < max ? () => onChanged(value + 1) : null,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderLight),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsBold.plus, size: 16, color: AppColors.textMain),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
