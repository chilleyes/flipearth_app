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
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('选择乘客', style: context.textStyles.h2.copyWith(fontSize: 22)),
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
                  Divider(height: 32, color: context.colors.borderLight),
                  _buildCounterRow(
                    title: '青年',
                    subtitle: '12 - 25 岁',
                    value: _youths,
                    onChanged: (v) => setState(() => _youths = v),
                  ),
                  Divider(height: 32, color: context.colors.borderLight),
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
                    backgroundColor: context.colors.textMain,
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
            Text(title, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: value > min ? () => onChanged(value - 1) : null,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: value > min ? Colors.white : context.colors.background,
                  border: Border.all(color: value > min ? context.colors.borderLight : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIconsBold.minus, size: 16, color: value > min ? context.colors.textMain : context.colors.textMuted),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            GestureDetector(
              onTap: value < max ? () => onChanged(value + 1) : null,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: context.colors.borderLight),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIconsBold.plus, size: 16, color: context.colors.textMain),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
