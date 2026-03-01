import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/models/trip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TripSegmentCard extends StatelessWidget {
  final TripSegment segment;
  final VoidCallback? onTapSearch;

  const TripSegmentCard({
    super.key,
    required this.segment,
    this.onTapSearch,
  });

  bool get _isBooked => segment.status == 'booked';
  bool get _isPlanned => segment.status == 'planned';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Ticket notch decorations on left & right ---
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    _buildRouteSection(context, colors, textStyles),
                    const SizedBox(height: 16),
                    _buildDividerWithNotches(colors),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, colors, textStyles),
                  ],
                ),
              ),
            ],
          ),
          if (_isPlanned) ...[
            const SizedBox(height: 4),
            _buildSearchButton(context, colors),
          ] else if (_isBooked) ...[
            const SizedBox(height: 4),
            _buildConfirmedBadge(context, colors, textStyles),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('HH:mm');
    final dateStr = dateFormat.format(segment.departureDate);
    final timeStr = timeFormat.format(segment.departureDate);

    return Row(
      children: [
        // From city
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segment.fromCity,
                style: textStyles.h3.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                segment.fromStationName ?? '',
                style: textStyles.caption.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(PhosphorIcons.calendarBlank(), size: 14, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Icon(PhosphorIcons.clock(), size: 14, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textMain,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Dashed line + train icon
        SizedBox(
          width: 72,
          child: Column(
            children: [
              Icon(
                PhosphorIcons.train(),
                size: 22,
                color: colors.brandBlue,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: CustomPaint(
                  painter: _DashedLinePainter(color: colors.textMuted.withOpacity(0.4)),
                  size: const Size(56, 1),
                ),
              ),
              const SizedBox(height: 4),
              if (segment.estimatedDuration != null)
                Text(
                  segment.estimatedDuration!,
                  style: textStyles.caption.copyWith(fontSize: 10, color: colors.textMuted),
                ),
            ],
          ),
        ),

        // To city
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                segment.toCity,
                style: textStyles.h3.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                segment.toStationName ?? '',
                style: textStyles.caption.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 6),
              if (_isBooked && segment.bookingReference != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    segment.bookingReference!,
                    style: textStyles.caption.copyWith(
                      color: colors.successGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDividerWithNotches(AppColorsExtension colors) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colors.background,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: _DashedLinePainter(
                  color: colors.borderLight,
                  dashWidth: 6,
                  dashSpace: 4,
                  strokeWidth: 1,
                ),
                size: Size(constraints.maxWidth, 1),
              );
            },
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colors.background,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Risk level indicator
          if (segment.riskLevel != null)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _riskColor(segment.riskLevel!),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  segment.riskNote ?? segment.riskLevel!,
                  style: textStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            )
          else
            const SizedBox.shrink(),

          // Price
          if (segment.estimatedPrice != null)
            Text(
              '${_currencySymbol(segment.currency)} ${segment.estimatedPrice!.toStringAsFixed(0)}',
              style: textStyles.bodyLarge.copyWith(
                color: colors.brandBlue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context, AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapSearch,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.brandBlue, colors.purpleGlow],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.magnifyingGlass(), size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Search Trains / Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmedBadge(BuildContext context, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colors.successGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.successGreen.withOpacity(0.2)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 18, color: colors.successGreen),
            const SizedBox(width: 8),
            Text(
              'Confirmed',
              style: textStyles.bodyMedium.copyWith(
                color: colors.successGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 3,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace;
}
