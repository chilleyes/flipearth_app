import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/models/trip.dart';
import '../../core/providers/service_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'trip_detail_page.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  final _tripService = ServiceProvider().tripService;
  List<TripSummary> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _tripService.getTrips();
      if (!mounted) return;
      setState(() {
        _trips = result.items;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ApiClient.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('我的行程', style: textStyles.h2),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _errorMessage != null
                      ? _buildError(colors, textStyles)
                      : _trips.isEmpty
                          ? _buildEmpty(colors, textStyles)
                          : RefreshIndicator(
                              onRefresh: _loadTrips,
                              color: colors.brandBlue,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                                itemCount: _trips.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) =>
                                    _TripCard(trip: _trips[index]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.warning(), size: 48, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: textStyles.bodyMedium.copyWith(color: colors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(onPressed: _loadTrips, child: Text('重试', style: textStyles.bodyMedium.copyWith(color: colors.brandBlue))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.suitcase(), size: 56, color: colors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('还没有行程', style: textStyles.h3.copyWith(color: colors.textMuted)),
            const SizedBox(height: 8),
            Text('去「规划」页面开启你的欧洲之旅吧', style: textStyles.bodySmall.copyWith(color: colors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripSummary trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final dateFormat = DateFormat('MMM d');
    final progress = trip.totalSegments > 0
        ? trip.bookedSegments / trip.totalSegments
        : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/trip_detail'),
            builder: (_) => TripDetailPage(tripId: trip.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.title,
                    style: textStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(status: trip.status, colors: colors, textStyles: textStyles),
              ],
            ),
            const SizedBox(height: 12),

            // Date + days
            Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(), size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${dateFormat.format(trip.startDate)} — ${dateFormat.format(trip.endDate)}',
                  style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.brandBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${trip.totalDays} 天',
                    style: textStyles.caption.copyWith(
                      color: colors.brandBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Row(
              children: [
                Icon(PhosphorIcons.train(), size: 14, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${trip.bookedSegments}/${trip.totalSegments} 段已购票',
                  style: textStyles.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? colors.successGreen : colors.brandBlue,
                ),
              ),
            ),

            // Price
            if (trip.estimatedTotalPrice > 0) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '预估总价 ',
                    style: textStyles.caption.copyWith(color: colors.textMuted),
                  ),
                  Text(
                    '${_currencySymbol(trip.currency)} ${trip.estimatedTotalPrice.toStringAsFixed(0)}',
                    style: textStyles.bodyLarge.copyWith(
                      color: colors.brandBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'USD': return '\$';
      default: return currency;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final AppColorsExtension colors;
  final AppTextStylesExtension textStyles;

  const _StatusChip({required this.status, required this.colors, required this.textStyles});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      'draft' => (colors.textMuted.withOpacity(0.1), colors.textMuted, '草稿'),
      'active' => (colors.brandBlue.withOpacity(0.1), colors.brandBlue, '进行中'),
      'completed' => (colors.successGreen.withOpacity(0.1), colors.successGreen, '已完成'),
      _ => (colors.textMuted.withOpacity(0.1), colors.textMuted, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: textStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
