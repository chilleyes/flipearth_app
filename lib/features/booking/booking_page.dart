import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/spring_button.dart';
import '../../core/models/train.dart';
import '../../core/models/booking_context.dart';
import '../../core/providers/service_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'widgets/checkout_sheet.dart';

class BookingPage extends StatefulWidget {
  final String originUic;
  final String destinationUic;
  final String originName;
  final String destinationName;
  final String date;
  final int adults;
  final int youth;
  final int children;
  final BookingContext? bookingContext;

  const BookingPage({
    super.key,
    this.originUic = '7015400',
    this.destinationUic = '8727100',
    this.originName = 'London',
    this.destinationName = 'Paris',
    this.date = '',
    this.adults = 1,
    this.youth = 0,
    this.children = 0,
    this.bookingContext,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _eurostarService = ServiceProvider().eurostarService;

  List<TrainResult> _trains = [];
  bool _isLoading = true;
  String? _error;
  int _selectedDateIndex = 0;
  late String _currentDate;
  late List<String> _dateLabels;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.date.isNotEmpty
        ? widget.date
        : _formatDateStr(DateTime.now().add(const Duration(days: 3)));
    _dateLabels = _buildDateLabels();
    _searchTrains();
  }

  String _formatDateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<String> _buildDateLabels() {
    final base = DateTime.tryParse(_currentDate) ?? DateTime.now();
    return List.generate(5, (i) {
      final d = base.add(Duration(days: i - 1));
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[d.weekday - 1]} ${d.day}';
    });
  }

  Future<void> _searchTrains({String? date}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final searchDate = date ?? _currentDate;
      final results = await _eurostarService.search(
        date: searchDate,
        origin: widget.originUic,
        destination: widget.destinationUic,
        adults: widget.adults,
        youth: widget.youth,
        children: widget.children,
      );
      if (mounted) {
        setState(() {
          _trains = results;
          _isLoading = false;
          if (date != null) _currentDate = date;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          if (widget.bookingContext != null)
            SliverToBoxAdapter(child: _buildTripContextBanner(context)),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在搜索车次...', style: TextStyle(color: Colors.grey)),
                  Text('该接口响应较慢，请耐心等待', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsFill.warningCircle,
                          size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text('搜索失败',
                          style: context.textStyles.h3),
                      const SizedBox(height: 8),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: context.textStyles.caption
                              .copyWith(color: context.colors.textMuted)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _searchTrains,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_trains.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.train,
                        size: 48, color: context.colors.textMuted),
                    const SizedBox(height: 16),
                    Text('该日期暂无可用车次',
                        style: context.textStyles.bodyMedium
                            .copyWith(color: context.colors.textMuted)),
                  ],
                ),
              ),
            )
          else
            _buildTrainList(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 180,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: context.colors.textMain.withOpacity(0.95),
            padding: const EdgeInsets.only(
                top: 60, left: 20, right: 20, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassIconButton(
                      icon: PhosphorIconsBold.arrowLeft,
                      onTap: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(widget.originName,
                                style: context.textStyles.h2.copyWith(
                                    color: Colors.white, fontSize: 18)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(PhosphorIconsBold.arrowRight,
                                  color: context.colors.brandBlue, size: 14),
                            ),
                            Text(widget.destinationName,
                                style: context.textStyles.h2.copyWith(
                                    color: Colors.white, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _currentDate.toUpperCase(),
                              style: context.textStyles.caption.copyWith(
                                  color: context.colors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                  color: context.colors.textMuted,
                                  shape: BoxShape.circle),
                            ),
                            Text(
                              '${widget.adults + widget.youth + widget.children} 位乘客',
                              style: context.textStyles.caption.copyWith(
                                  color: context.colors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildGlassIconButton(
                      icon: PhosphorIconsBold.slidersHorizontal,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dateLabels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedDateIndex;
                      return _buildDateCard(
                        date: _dateLabels[index],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedDateIndex = index);
                          final base =
                              DateTime.tryParse(_currentDate) ??
                                  DateTime.now();
                          final newDate =
                              base.add(Duration(days: index - 1));
                          _searchTrains(date: _formatDateStr(newDate));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildGlassIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildDateCard({
    required String date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SpringButton(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandBlue
              : Colors.white.withOpacity(0.05),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: context.colors.brandBlue.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            date.toUpperCase(),
            textAlign: TextAlign.center,
            style: context.textStyles.caption.copyWith(
              color: isSelected
                  ? Colors.white
                  : context.colors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrainList() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= _trains.length) return null;
            final train = _trains[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTrainCard(train, isFastest: index == 0),
            );
          },
          childCount: _trains.length,
        ),
      ),
    );
  }

  Widget _buildTrainCard(TrainResult train, {bool isFastest = false}) {
    final cheapest = train.cheapestPrice;
    final currency = train.cheapestCurrency;
    final standardAvail =
        train.prices['standard']?.availability ?? 'none';

    return SpringButton(
      onTap: () => _showCheckoutBottomSheet(context, train),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFastest
                ? context.colors.brandBlue.withOpacity(0.3)
                : context.colors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 5)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (isFastest)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.brandBlue.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsFill.lightning,
                          color: context.colors.brandBlue, size: 12),
                      const SizedBox(width: 4),
                      Text('最快到达',
                          style: context.textStyles.caption.copyWith(
                              color: context.colors.brandBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildTimeRow(train.departureTime,
                                train.origin.name,
                                isStart: true),
                            const SizedBox(height: 16),
                            _buildTimeRow(train.arrivalTime,
                                train.destination.name,
                                isStart: false),
                          ],
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 60,
                          color: context.colors.borderLight),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('STANDARD起',
                                style: context.textStyles.caption.copyWith(
                                    color: context.colors.textMuted,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text(
                              cheapest != null
                                  ? '€${cheapest.toStringAsFixed(0)}'
                                  : 'N/A',
                              style: context.textStyles.h1.copyWith(
                                  fontSize: 32, letterSpacing: -1.0),
                            ),
                            if (standardAvail != 'none') ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: _availColor(standardAvail)
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(4)),
                                child: Text(
                                  _availLabel(standardAvail),
                                  style: context.textStyles.caption
                                      .copyWith(
                                          color: _availColor(
                                              standardAvail),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      border:
                          Border.all(color: context.colors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.clock,
                            color: context.colors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Text(train.duration,
                            style: context.textStyles.caption.copyWith(
                                color: context.colors.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12),
                          decoration: BoxDecoration(
                              color: context.colors.textMuted,
                              shape: BoxShape.circle),
                        ),
                        Icon(PhosphorIconsFill.train,
                            color: context.colors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${train.trainNumber}${train.isDirect ? ' (直达)' : ''}',
                          style: context.textStyles.caption.copyWith(
                              color: context.colors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _availColor(String avail) {
    switch (avail) {
      case 'high':
        return const Color(0xFF059669);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _availLabel(String avail) {
    switch (avail) {
      case 'high':
        return '余票充足';
      case 'medium':
        return '余票紧张';
      case 'low':
        return '仅剩少量';
      default:
        return '';
    }
  }

  Widget _buildTimeRow(String time, String station,
      {required bool isStart}) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(time,
              style: context.textStyles.h2
                  .copyWith(fontSize: 22, letterSpacing: -0.5)),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color: isStart
                    ? context.colors.textMain
                    : context.colors.brandBlue,
                width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(station,
              style: context.textStyles.caption.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTripContextBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.successGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.suitcase(PhosphorIconsStyle.fill),
              size: 18, color: context.colors.successGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '来自你的行程计划',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.successGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutBottomSheet(BuildContext context, TrainResult train) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CheckoutSheet(
          train: train,
          date: _currentDate,
          adults: widget.adults,
          youth: widget.youth,
          childrenCount: widget.children,
          bookingContext: widget.bookingContext,
        );
      },
    );
  }
}
