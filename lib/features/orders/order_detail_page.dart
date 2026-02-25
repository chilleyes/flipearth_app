import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/order.dart';
import '../../core/providers/service_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final String bookingRef;

  const OrderDetailPage({super.key, required this.bookingRef});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _orderService = ServiceProvider().orderService;
  TrainOrderDetail? _detail;
  bool _isLoading = true;
  String? _error;
  bool _isRefunding = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail =
          await _orderService.getTrainOrderDetail(widget.bookingRef);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
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

  Future<void> _requestRefund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认退票'),
        content: Text(
          _detail?.refundData != null
              ? '退票手续费 €${_detail!.refundData!.fee.toStringAsFixed(2)}，实际退款 €${_detail!.refundData!.amount.toStringAsFixed(2)}。确定要申请退票吗？'
              : '确定要申请退票吗？',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认退票')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRefunding = true);
    try {
      await _orderService.requestRefund(widget.bookingRef);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('退票申请已提交，预计3-5个工作日处理')),
        );
        _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退票失败: $e')),
        );
      }
    }
    if (mounted) setState(() => _isRefunding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: const Text('订单详情'),
          leading: IconButton(
            icon: const Icon(PhosphorIconsBold.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsFill.warningCircle,
                  size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(_error ?? '加载失败'),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadDetail, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    final d = _detail!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(context, d),
              SliverToBoxAdapter(child: _buildDetailsContent(d)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildBottomActionRow(context, d),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TrainOrderDetail d) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: context.colors.textMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: context.colors.textMain),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  height: 2, color: context.colors.brandBlue),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                    color: context.colors.brandBlue.withOpacity(0.2)),
              ),
            ),
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EUROSTAR ${d.journey.travelClass.toUpperCase()}',
                        style: context.textStyles.caption.copyWith(
                            color: context.colors.brandBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.journey.origin}到${d.journey.destination}',
                        style: context.textStyles.h1
                            .copyWith(color: Colors.white, fontSize: 28),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBgColor(d.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      d.statusLabel ?? d.status,
                      style: context.textStyles.caption.copyWith(
                          color: _statusTextColor(d.status),
                          fontWeight: FontWeight.w900,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassIconButton(
              icon: PhosphorIconsBold.arrowLeft,
              onTap: () => Navigator.pop(context)),
          _buildGlassIconButton(
              icon: PhosphorIconsBold.downloadSimple, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent(TrainOrderDetail d) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.borderLight),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('订单号: ${d.bookingReference}',
                          style: context.textStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.textMuted)),
                      if (d.journey.pnr != null)
                        Text('PNR: ${d.journey.pnr}',
                            style: context.textStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.brandBlue)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                              d.journey.departureTime.contains(' ')
                                  ? d.journey.departureTime.split(' ')[1].substring(0, 5)
                                  : d.journey.departureTime,
                              style: context.textStyles.h1
                                  .copyWith(fontSize: 28, letterSpacing: -1.0)),
                          const SizedBox(height: 4),
                          Text(d.journey.origin,
                              style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textMuted)),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Text(d.journey.trainNumber,
                                  style: context.textStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.textMuted,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              Icon(PhosphorIconsFill.train,
                                  color: context.colors.brandBlue, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                  d.journey.isDirect ? '直达' : '${d.journey.legCount}段',
                                  style: context.textStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.textMuted,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              d.journey.arrivalTime.contains(' ')
                                  ? d.journey.arrivalTime.split(' ')[1].substring(0, 5)
                                  : d.journey.arrivalTime,
                              style: context.textStyles.h1
                                  .copyWith(fontSize: 28, letterSpacing: -1.0)),
                          const SizedBox(height: 4),
                          Text(d.journey.destination,
                              style: context.textStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (d.journey.coach != null || d.journey.seat != null)
                    Row(
                      children: [
                        if (d.journey.coach != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: context.colors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('车厢',
                                      style: context.textStyles.caption
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  context.colors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(d.journey.coach!,
                                      style: context.textStyles.h1
                                          .copyWith(fontSize: 24)),
                                ],
                              ),
                            ),
                          ),
                        if (d.journey.coach != null &&
                            d.journey.seat != null)
                          const SizedBox(width: 12),
                        if (d.journey.seat != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: context.colors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('座位',
                                      style: context.textStyles.caption
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  context.colors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(d.journey.seat!,
                                      style: context.textStyles.h1
                                          .copyWith(fontSize: 24)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (d.travelers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text('乘客信息',
                    style: context.textStyles.h3.copyWith(fontSize: 18)),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderLight),
                ),
                child: Column(
                  children: [
                    ...d.travelers.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('${t.lastName} / ${t.firstName}',
                                      style: context.textStyles.bodyMedium
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                  Text('${t.type} · ${t.title}',
                                      style: context.textStyles.caption
                                          .copyWith(
                                              color:
                                                  context.colors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        )),
                    Divider(
                        color: context.colors.borderLight,
                        height: 1,
                        thickness: 1),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                        '票价', '€ ${d.price.toStringAsFixed(2)}'),
                    if (d.cnyAmount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildPriceRow(
                            '人民币约',
                            '¥ ${d.cnyAmount!.toStringAsFixed(2)}'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: context.textStyles.caption.copyWith(
                color: context.colors.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 13)),
        Text(value,
            style: context.textStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomActionRow(BuildContext context, TrainOrderDetail d) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
            top: 16, bottom: 32, left: 24, right: 24),
        decoration: BoxDecoration(
          color: context.colors.background.withOpacity(0.9),
          border:
              Border(top: BorderSide(color: context.colors.borderLight)),
        ),
        child: Row(
          children: [
            if (d.canRefund)
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRefunding ? null : _requestRefund,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.textSecondary,
                    elevation: 0,
                    side: BorderSide(color: context.colors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isRefunding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(PhosphorIconsBold.arrowUDownLeft,
                                size: 18),
                            const SizedBox(width: 6),
                            Text('申请退票',
                                style: context.textStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            if (d.canRefund) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.textMain,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsBold.headset, size: 18),
                    const SizedBox(width: 6),
                    Text('联系客服',
                        style: context.textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'paid':
      case '4':
        return const Color(0xFFD1FAE5);
      case 'refund_auditing':
        return const Color(0xFFFEF3C7);
      default:
        return context.colors.borderLight;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'paid':
      case '4':
        return const Color(0xFF047857);
      case 'refund_auditing':
        return const Color(0xFFF59E0B);
      default:
        return context.colors.textMuted;
    }
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;

  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
