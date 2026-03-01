import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/spring_button.dart';
import '../../core/models/train.dart';
import '../../core/models/booking.dart';
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
  bool _isCreatingBooking = false;

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
      body: Stack(
        children: [
          CustomScrollView(
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
          if (_isCreatingBooking)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('正在创建订单...', style: context.textStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('锁定票价中，请稍候',
                          style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
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
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFastest
              ? colors.brandBlue.withOpacity(0.3)
              : colors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 5)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFastest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              color: colors.brandBlue.withOpacity(0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsFill.lightning,
                      color: colors.brandBlue, size: 12),
                  const SizedBox(width: 4),
                  Text('最快到达',
                      style: textStyles.caption.copyWith(
                          color: colors.brandBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 10)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                _buildTimeColumn(textStyles, colors, train.departureTime, train.origin.name, true),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildTimeDot(colors, true),
                          Expanded(child: Container(height: 1.5, color: colors.borderLight)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.borderLight),
                            ),
                            child: Text(
                              train.duration,
                              style: textStyles.caption.copyWith(fontSize: 9, color: colors.textMuted, fontWeight: FontWeight.w800),
                            ),
                          ),
                          Expanded(child: Container(height: 1.5, color: colors.borderLight)),
                          _buildTimeDot(colors, false),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            train.isDirect ? PhosphorIconsFill.arrowRight : PhosphorIconsFill.shuffle,
                            size: 10,
                            color: train.isDirect ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            train.isDirect ? '直达' : '${train.legCount - 1}次换乘',
                            style: textStyles.caption.copyWith(
                              fontSize: 9,
                              color: train.isDirect ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildTimeColumn(textStyles, colors, train.arrivalTime, train.destination.name, false),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 2),
            child: Text(
              train.trainNumber,
              style: textStyles.caption.copyWith(fontSize: 9, color: colors.textMuted),
            ),
          ),

          Divider(height: 1, color: colors.borderLight),

          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
            child: Row(
              children: [
                _buildFareColumn(colors, textStyles, train, 'standard', 'Standard'),
                _buildFareDivider(colors),
                _buildFareColumn(colors, textStyles, train, 'plus', 'Plus'),
                _buildFareDivider(colors),
                _buildFareColumn(colors, textStyles, train, 'premier', 'Premier'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(AppTextStylesExtension textStyles, AppColorsExtension colors, String time, String station, bool isStart) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: textStyles.h2.copyWith(fontSize: 22, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            station,
            style: textStyles.caption.copyWith(
                color: colors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isStart ? TextAlign.left : TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDot(AppColorsExtension colors, bool isStart) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isStart ? colors.textMain : colors.brandBlue,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildFareDivider(AppColorsExtension colors) {
    return Container(width: 1, height: 50, color: colors.borderLight);
  }

  Widget _buildFareColumn(
    AppColorsExtension colors,
    AppTextStylesExtension textStyles,
    TrainResult train,
    String fareKey,
    String fareLabel,
  ) {
    final option = train.prices[fareKey];
    final hasPrice = option != null && option.price > 0;

    return Expanded(
      child: SpringButton(
        onTap: () {
          if (hasPrice && !_isCreatingBooking) {
            _createBookingAndCheckout(train, selectedClass: fareKey);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fareLabel.toUpperCase(),
                style: textStyles.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              if (!hasPrice)
                Text(
                  '-',
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.borderLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else ...[
                if (option!.hasDiscount) ...[
                  Text(
                    '€${option.price.toStringAsFixed(0)}',
                    style: textStyles.h3.copyWith(
                      color: const Color(0xFFD97706),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '€${option.originalPrice!.toStringAsFixed(0)}',
                    style: textStyles.caption.copyWith(
                      color: colors.textMuted,
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: colors.textMuted,
                    ),
                  ),
                ] else
                  Text(
                    '€${option.price.toStringAsFixed(0)}',
                    style: textStyles.h3.copyWith(
                      color: const Color(0xFF15803D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
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

  Future<void> _createBookingAndCheckout(TrainResult train, {String selectedClass = 'standard'}) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _isCreatingBooking = true);

    try {
      final classOfferId = train.prices[selectedClass]?.offerId;
      final finalOfferId = classOfferId ?? train.offerId;

      debugPrint('[Booking] offerId=$finalOfferId (class=$classOfferId, root=${train.offerId})');
      debugPrint('[Booking] searchId=${train.searchId}, trainId=${train.trainId}, class=$selectedClass');

      final booking = await _eurostarService.createBooking(
        offerId: finalOfferId,
        searchId: train.searchId,
        trainId: train.trainId,
        travelClass: selectedClass,
        date: _currentDate,
        adults: widget.adults,
        youth: widget.youth,
        children: widget.children,
        origin: train.origin.name,
        destination: train.destination.name,
        originUic: train.origin.uic,
        destinationUic: train.destination.uic,
        trainNumber: train.trainNumber,
        departureTime: train.departureTime,
        arrivalTime: train.arrivalTime,
        isDirect: train.isDirect,
        legCount: train.legCount,
        segments: train.segments.map((s) => s.toJson()).toList(),
      );

      if (!mounted) return;
      setState(() => _isCreatingBooking = false);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return CheckoutSheet(
            train: train,
            booking: booking,
            date: _currentDate,
            selectedClass: selectedClass,
            adults: widget.adults,
            youth: widget.youth,
            childrenCount: widget.children,
            bookingContext: widget.bookingContext,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingBooking = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建订单失败: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
