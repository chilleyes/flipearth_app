import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum SeatState { available, occupied, selected }

class SeatSelectionPage extends StatefulWidget {
  final int requiredSeats;

  const SeatSelectionPage({super.key, this.requiredSeats = 1});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  // A simple 2D map for a carriage: 12 rows, 4 seats per row
  // 0: A, 1: B, (aisle), 2: C, 3: D
  final Map<String, SeatState> _seatStates = {};
  final List<String> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    // Generate mock seats
    for (int row = 1; row <= 12; row++) {
      for (var col in ['A', 'B', 'C', 'D']) {
        final seatId = '$row$col';
        // Randomly set some as occupied
        if ((row == 3 && col == 'B') || 
            (row == 4 && col == 'C') || 
            (row == 7 && col == 'A') || 
            (row == 7 && col == 'B') || 
            (row == 11 && col == 'D')) {
          _seatStates[seatId] = SeatState.occupied;
        } else {
          _seatStates[seatId] = SeatState.available;
        }
      }
    }
  }

  void _toggleSeat(String seatId) {
    if (_seatStates[seatId] == SeatState.occupied) return;

    HapticFeedback.lightImpact();

    setState(() {
      if (_seatStates[seatId] == SeatState.selected) {
        _seatStates[seatId] = SeatState.available;
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length < widget.requiredSeats) {
          _seatStates[seatId] = SeatState.selected;
          _selectedSeats.add(seatId);
        } else if (widget.requiredSeats == 1) {
          // If only 1 seat needed, auto-swap the selection
          final previous = _selectedSeats.first;
          _seatStates[previous] = SeatState.available;
          _selectedSeats.clear();
          
          _seatStates[seatId] = SeatState.selected;
          _selectedSeats.add(seatId);
        } else {
          // Max seats reached, give a subtle buzz
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.caretLeft, color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('选择您的座位', style: context.textStyles.h3.copyWith(fontSize: 17)),
            Text('Carriage 09 • Standard', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Legend
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context.colors.borderLight, '已被占用'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.white, '可选', showBorder: true),
                const SizedBox(width: 24),
                _buildLegendItem(context.colors.brandBlue, '已选中'),
              ],
            ),
          ),
          
          Divider(height: 1, color: context.colors.borderLight),
          
          // Seat Map Area
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(40),
              minScale: 0.8,
              maxScale: 2.5,
              child: Center(
                child: _buildTrainCarriage(),
              ),
            ),
          ),
          
          // Bottom Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool showBorder = false}) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: showBorder ? Border.all(color: context.colors.borderLight, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textMain, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrainCarriage() {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: context.colors.borderLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Front of the carriage indicator
          const SizedBox(height: 24),
          Icon(PhosphorIconsBold.arrowUp, color: context.colors.borderLight),
          const SizedBox(height: 8),
          Text('列车运行方向', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
          const SizedBox(height: 32),
          
          // Seats Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(12, (index) => _buildRow(index + 1)),
            ),
          ),
          
          const SizedBox(height: 32),
          // Back of carriage
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(38)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int rowInfo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left pair
          Row(
            children: [
              _buildSeat('$rowInfo', 'A'),
              const SizedBox(width: 8),
              _buildSeat('$rowInfo', 'B'),
            ],
          ),
          // Aisle row indicator
          SizedBox(
            width: 30,
            child: Center(
              child: Text('$rowInfo', style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.bold)),
            ),
          ),
          // Right pair
          Row(
            children: [
              _buildSeat('$rowInfo', 'C'),
              const SizedBox(width: 8),
              _buildSeat('$rowInfo', 'D'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(String row, String col) {
    final seatId = '$row$col';
    final state = _seatStates[seatId] ?? SeatState.occupied;
    
    Color bgColor;
    Color borderColor;
    
    switch (state) {
      case SeatState.available:
        bgColor = Colors.white;
        borderColor = context.colors.borderLight;
        break;
      case SeatState.occupied:
        bgColor = context.colors.borderLight;
        borderColor = Colors.transparent;
        break;
      case SeatState.selected:
        bgColor = context.colors.brandBlue;
        borderColor = context.colors.brandBlue;
        break;
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seatId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: 36,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Small dot to represent the headrest
              Container(
                width: 16, height: 4,
                decoration: BoxDecoration(
                  color: state == SeatState.occupied ? Colors.white54 : 
                         state == SeatState.selected ? Colors.white : context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              if (state == SeatState.selected)
                const Icon(PhosphorIconsBold.check, color: Colors.white, size: 16)
              else if (state == SeatState.occupied)
                const Icon(PhosphorIconsBold.x, color: Colors.white, size: 16)
              else
                Text(col, style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool canConfirm = _selectedSeats.length == widget.requiredSeats;
    
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 40, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_selectedSeats.length} / ${widget.requiredSeats} 已选', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
              const SizedBox(height: 4),
              Text(
                _selectedSeats.isEmpty ? '请点选座位' : _selectedSeats.join(', '), 
                style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.colors.brandBlue),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: canConfirm ? () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, _selectedSeats.join(', '));
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canConfirm ? context.colors.brandBlue : context.colors.borderLight,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('确认选座', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
