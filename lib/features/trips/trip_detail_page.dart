import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/models/trip.dart';
import '../../core/providers/service_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../visa/visa_export_page.dart';
import 'widgets/trip_segment_card.dart';

class TripDetailPage extends StatefulWidget {
  final int tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  final _tripService = ServiceProvider().tripService;
  TripDetail? _trip;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _tripService.getTripDetail(widget.tripId);
      if (!mounted) return;
      setState(() {
        _trip = detail;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _errorMessage != null
              ? _buildError(colors, textStyles)
              : _buildContent(colors, textStyles),
    );
  }

  Widget _buildError(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.warning(), size: 48, color: colors.textMuted),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: textStyles.bodyMedium.copyWith(color: colors.textMuted), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextButton(onPressed: _loadDetail, child: Text('重试', style: textStyles.bodyMedium.copyWith(color: colors.brandBlue))),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('返回', style: textStyles.bodyMedium.copyWith(color: colors.textMuted))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final trip = _trip!;
    return CustomScrollView(
      slivers: [
        _buildHeroHeader(trip, colors, textStyles),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              _buildTimeline(trip, colors, textStyles),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverToBoxAdapter(child: _buildVisaButton(colors, textStyles)),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(TripDetail trip, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: colors.brandBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.brandBlue, colors.purpleGlow.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    trip.title,
                    style: textStyles.h2.copyWith(color: Colors.white, fontSize: 26),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(PhosphorIcons.calendarBlank(), size: 16, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(trip.startDate)} — ${dateFormat.format(trip.endDate)}',
                        style: textStyles.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _HeroPill(
                        icon: PhosphorIcons.mapPin(),
                        text: '${trip.totalDays} 天',
                        colors: colors,
                      ),
                      const SizedBox(width: 10),
                      _HeroPill(
                        icon: PhosphorIcons.train(),
                        text: '${trip.segments.where((s) => s.status == 'booked').length}/${trip.segments.length} 段已购',
                        colors: colors,
                      ),
                      const Spacer(),
                      if (trip.estimatedTotalPrice > 0)
                        Text(
                          '${_currencySymbol(trip.currency)} ${trip.estimatedTotalPrice.toStringAsFixed(0)}',
                          style: textStyles.h3.copyWith(color: Colors.white, fontSize: 22),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
    );
  }

  /// Build interleaved timeline: Stay → Segment → Stay → Segment → Stay
  List<Widget> _buildTimeline(TripDetail trip, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final stays = List<TripStay>.from(trip.stays)..sort((a, b) => a.stayOrder.compareTo(b.stayOrder));
    final segments = List<TripSegment>.from(trip.segments)..sort((a, b) => a.segmentOrder.compareTo(b.segmentOrder));

    final List<Widget> items = [];
    int segIdx = 0;

    for (int i = 0; i < stays.length; i++) {
      items.add(_StayBlock(stay: stays[i], colors: colors, textStyles: textStyles));

      if (segIdx < segments.length) {
        items.add(const SizedBox(height: 4));
        items.add(_buildTimelineConnector(colors));
        items.add(const SizedBox(height: 4));
        items.add(
          TripSegmentCard(
            segment: segments[segIdx],
            onTapSearch: segments[segIdx].status == 'planned'
                ? () {
                    // TODO: Navigate to search/booking flow with segment context
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('搜票功能即将上线: ${segments[segIdx].fromCity} → ${segments[segIdx].toCity}')),
                    );
                  }
                : null,
          ),
        );
        segIdx++;
      }

      if (i < stays.length - 1) {
        items.add(const SizedBox(height: 4));
        items.add(_buildTimelineConnector(colors));
        items.add(const SizedBox(height: 4));
      }
    }

    // Remaining segments without a following stay
    while (segIdx < segments.length) {
      items.add(const SizedBox(height: 4));
      items.add(_buildTimelineConnector(colors));
      items.add(const SizedBox(height: 4));
      final seg = segments[segIdx];
      items.add(
        TripSegmentCard(
          segment: seg,
          onTapSearch: seg.status == 'planned'
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('搜票功能即将上线: ${seg.fromCity} → ${seg.toCity}')),
                  );
                }
              : null,
        ),
      );
      segIdx++;
    }

    return items;
  }

  Widget _buildTimelineConnector(AppColorsExtension colors) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Column(
          children: List.generate(3, (_) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                width: 3,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVisaButton(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VisaExportPage(tripId: widget.tripId)),
        );
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.brandBlue.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.fileText(), size: 20, color: colors.brandBlue),
          const SizedBox(width: 10),
          Text(
            'Generate Visa Itinerary',
            style: textStyles.bodyMedium.copyWith(
              color: colors.brandBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppColorsExtension colors;

  const _HeroPill({required this.icon, required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StayBlock extends StatelessWidget {
  final TripStay stay;
  final AppColorsExtension colors;
  final AppTextStylesExtension textStyles;

  const _StayBlock({required this.stay, required this.colors, required this.textStyles});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.brandBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), size: 22, color: colors.brandBlue),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(stay.city, style: textStyles.bodyLarge),
                    if (stay.country != null) ...[
                      const SizedBox(width: 6),
                      Text(stay.country!, style: textStyles.caption.copyWith(color: colors.textMuted)),
                    ],
                    if (stay.isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.purpleGlow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('可选', style: textStyles.caption.copyWith(color: colors.purpleGlow, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(stay.checkInDate)} — ${dateFormat.format(stay.checkOutDate)}  ·  ${stay.nights} 晚',
                  style: textStyles.bodySmall.copyWith(color: colors.textMuted),
                ),
                if (stay.accommodationName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    stay.accommodationName!,
                    style: textStyles.caption.copyWith(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
