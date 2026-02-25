import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CalendarBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool isOutbound;

  const CalendarBottomSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.isOutbound = true,
  });

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  int get _daysInMonth {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    return nextMonth.day;
  }

  int get _firstDayOffset {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return firstDay.weekday - 1; // 0 for Monday
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _previousMonth() {
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    if (prevMonth.isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1))) {
      setState(() {
        _focusedMonth = prevMonth;
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateDisabled(DateTime date) {
    return date.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) ||
           date.isAfter(widget.lastDate);
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOutbound ? '选择出发日期' : '选择返程日期',
                  style: context.textStyles.h2,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.borderLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsRegular.x, size: 20, color: context.colors.textMain),
                  ),
                ),
              ],
            ),
          ),

          // Month Navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsBold.caretLeft),
                  color: _focusedMonth.isAfter(DateTime(widget.firstDate.year, widget.firstDate.month)) 
                      ? context.colors.textMain 
                      : context.colors.borderLight,
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_focusedMonth.year}年 ${_focusedMonth.month}月',
                  style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsBold.caretRight),
                  color: context.colors.textMain,
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Weekday Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((day) => SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    day,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Calendar Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _daysInMonth + _firstDayOffset,
                itemBuilder: (context, index) {
                  if (index < _firstDayOffset) {
                    return const SizedBox.shrink();
                  }

                  final day = index - _firstDayOffset + 1;
                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isDisabled = _isDateDisabled(date);
                  final isToday = _isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: isDisabled ? null : () {
                      setState(() {
                        _selectedDate = date;
                      });
                      // Add slight delay before returning
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (context.mounted) {
                          Navigator.pop(context, _selectedDate);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.brandBlue : (isToday ? context.colors.brandBlue.withOpacity(0.1) : Colors.transparent),
                        shape: BoxShape.circle,
                        border: isToday && !isSelected ? Border.all(color: context.colors.brandBlue.withOpacity(0.5)) : null,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: context.textStyles.bodyMedium.copyWith(
                            color: isDisabled 
                                ? context.colors.borderLight 
                                : isSelected 
                                    ? Colors.white 
                                    : (isToday ? context.colors.brandBlue : context.colors.textMain),
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
