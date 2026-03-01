import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/train.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/traveler.dart';
import '../../../core/models/order.dart';
import '../../../core/models/booking_context.dart';
import '../../../core/providers/service_provider.dart';
import '../payment_success_page.dart';
import '../../profile/add_traveler_page.dart';

class CheckoutSheet extends StatefulWidget {
  final TrainResult train;
  final BookingResult booking;
  final String date;
  final String selectedClass;
  final int adults;
  final int youth;
  final int childrenCount;
  final BookingContext? bookingContext;

  const CheckoutSheet({
    super.key,
    required this.train,
    required this.booking,
    required this.date,
    this.selectedClass = 'standard',
    this.adults = 1,
    this.youth = 0,
    this.childrenCount = 0,
    this.bookingContext,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _services = ServiceProvider();

  bool _isProcessing = false;
  String? _error;
  List<Traveler> _travelers = [];
  bool _loadingTravelers = true;
  Traveler? _selectedTraveler;

  static const _classLabels = {
    'standard': 'Standard',
    'plus': 'Plus',
    'premier': 'Premier',
  };

  double get _price => widget.booking.price > 0
      ? widget.booking.price
      : widget.train.prices[widget.selectedClass]?.price ?? 0;

  String get _currency => widget.booking.currency.isNotEmpty
      ? widget.booking.currency
      : 'EUR';

  String get _classLabel => _classLabels[widget.selectedClass] ?? widget.selectedClass;

  @override
  void initState() {
    super.initState();
    _loadTravelers();
  }

  Future<void> _loadTravelers() async {
    try {
      final travelers = await _services.userService.getTravelers();
      if (mounted) {
        setState(() {
          _travelers = travelers;
          _selectedTraveler = travelers.isNotEmpty
              ? travelers.firstWhere((t) => t.isDefault,
                  orElse: () => travelers.first)
              : null;
          _loadingTravelers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingTravelers = false);
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedTraveler == null) {
      setState(() => _error = '请先添加乘车人信息');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final traveler = _selectedTraveler!;
      final travelerInfo = TravelerInfo(
        firstName: traveler.firstName,
        lastName: traveler.lastName,
        title: traveler.title,
        type: traveler.type,
        dateOfBirth: traveler.dateOfBirth,
        leadTraveler: true,
        emailAddress: traveler.email,
        phoneNumber: traveler.phone,
      );

      final classOfferId = widget.train.prices[widget.selectedClass]?.offerId;

      await _services.eurostarService.preorder(
        bookingId: widget.booking.bookingId,
        itemId: widget.booking.itemId,
        offerId: classOfferId ?? widget.train.offerId,
        searchId: widget.train.searchId,
        paymentMethod: 'stripe',
        travelers: [travelerInfo],
      );

      final intent = await _services.paymentService
          .createStripeIntent(widget.booking.bookingReference);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              bookingReference: widget.booking.bookingReference,
              amount: intent.amount,
              currency: intent.currency,
              bookingContext: widget.bookingContext,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('确认订单',
                          style: context.textStyles.h1.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                          '${widget.train.departureTime} 出发 · ${widget.train.origin.name}至${widget.train.destination.name}',
                          style: context.textStyles.bodyMedium
                              .copyWith(color: context.colors.textMuted)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(PhosphorIconsBold.x,
                        size: 16, color: context.colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          _buildBookingRefBanner(context),

          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!,
                        style: context.textStyles.caption
                            .copyWith(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildSelectedClassInfo(context),
                const SizedBox(height: 24),
                _buildTravelerSection(),
                const SizedBox(height: 16),
                _buildPriceSummary(),
              ],
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBookingRefBanner(BuildContext context) {
    if (widget.booking.bookingReference.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.successGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.checkCircle,
              size: 16, color: context.colors.successGreen),
          const SizedBox(width: 8),
          Text(
            '订单已锁定 · ${widget.booking.bookingReference}',
            style: context.textStyles.caption.copyWith(
              color: context.colors.successGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedClassInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.brandBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _classLabel,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.brandBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '€${_price.toStringAsFixed(2)}',
            style: context.textStyles.h2.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('乘车人信息',
                  style: context.textStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddTravelerPage()),
                  );
                  _loadTravelers();
                },
                child: Row(
                  children: [
                    Icon(PhosphorIconsBold.plus,
                        color: context.colors.brandBlue, size: 14),
                    const SizedBox(width: 4),
                    Text('管理乘车人',
                        style: context.textStyles.caption.copyWith(
                            color: context.colors.brandBlue,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingTravelers)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_travelers.isEmpty)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddTravelerPage()),
                );
                _loadTravelers();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: context.colors.brandBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsBold.plus,
                        color: context.colors.brandBlue, size: 18),
                    const SizedBox(width: 8),
                    Text('添加乘车人',
                        style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.brandBlue,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            ...(_travelers.map((t) => _buildTravelerTile(t))),
        ],
      ),
    );
  }

  Widget _buildTravelerTile(Traveler traveler) {
    final isSelected = _selectedTraveler?.id == traveler.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTraveler = traveler),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandBlue.withOpacity(0.05)
              : context.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? context.colors.brandBlue.withOpacity(0.3)
                  : context.colors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: context.colors.brandBlue.withOpacity(0.1),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(traveler.initials,
                  style: context.textStyles.bodyMedium.copyWith(
                      color: context.colors.brandBlue,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(traveler.fullName,
                      style: context.textStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  if (traveler.passportNumber != null)
                    Text('护照: ${traveler.passportNumber}',
                        style: context.textStyles.caption
                            .copyWith(color: context.colors.textMuted)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(PhosphorIconsFill.checkCircle,
                  color: Color(0xFF10B981), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            '${widget.train.origin.name} → ${widget.train.destination.name} ($_classLabel)',
            '€${_price.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('税费及服务费', '€0.00'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                color: context.colors.borderLight, height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('总价',
                  style: context.textStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('€${_price.toStringAsFixed(2)}',
                  style: context.textStyles.h1.copyWith(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
              style: context.textStyles.caption.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ),
        Text(value,
            style: context.textStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: context.colors.borderLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            elevation: 5,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsFill.creditCard,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                        '支付 €${_price.toStringAsFixed(2)}',
                        style: context.textStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
        ),
      ),
    );
  }
}
