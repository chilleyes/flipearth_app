import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/train.dart';
import '../../../core/models/traveler.dart';
import '../../../core/models/order.dart';
import '../../../core/providers/service_provider.dart';
import '../payment_success_page.dart';
import '../../profile/add_traveler_page.dart';

class CheckoutSheet extends StatefulWidget {
  final TrainResult train;
  final String date;
  final int adults;
  final int youth;
  final int childrenCount;

  const CheckoutSheet({
    super.key,
    required this.train,
    required this.date,
    this.adults = 1,
    this.youth = 0,
    this.childrenCount = 0,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _services = ServiceProvider();

  int _selectedClassIndex = 0;
  bool _isProcessing = false;
  String? _error;
  List<Traveler> _travelers = [];
  bool _loadingTravelers = true;
  Traveler? _selectedTraveler;

  final _classNames = ['standard', 'premier', 'business'];
  final _classLabels = ['Standard', 'Premier', 'Business'];

  @override
  void initState() {
    super.initState();
    _loadTravelers();
  }

  double get _selectedPrice {
    final className = _classNames[_selectedClassIndex];
    return widget.train.prices[className]?.price ?? 0;
  }

  String get _selectedCurrency {
    final className = _classNames[_selectedClassIndex];
    return widget.train.prices[className]?.currency ?? 'EUR';
  }

  Future<void> _loadTravelers() async {
    try {
      final travelers = await _services.userService.getTravelers();
      if (mounted) {
        setState(() {
          _travelers = travelers;
          _selectedTraveler =
              travelers.isNotEmpty ? travelers.firstWhere((t) => t.isDefault, orElse: () => travelers.first) : null;
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
      final booking = await _services.eurostarService.createBooking(
        offerId: widget.train.offerId,
        searchId: widget.train.searchId,
        trainId: widget.train.trainId,
        travelClass: _classNames[_selectedClassIndex],
        date: widget.date,
        adults: widget.adults,
        youth: widget.youth,
        children: widget.childrenCount,
        origin: widget.train.origin.name,
        destination: widget.train.destination.name,
        originUic: widget.train.origin.uic,
        destinationUic: widget.train.destination.uic,
        trainNumber: widget.train.trainNumber,
        departureTime: widget.train.departureTime,
        arrivalTime: widget.train.arrivalTime,
        isDirect: widget.train.isDirect,
        legCount: widget.train.legCount,
        segments: widget.train.segments.map((s) => s.toJson()).toList(),
      );

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

      await _services.eurostarService.preorder(
        bookingId: booking.bookingId,
        itemId: booking.itemId,
        offerId: widget.train.offerId,
        searchId: widget.train.searchId,
        paymentMethod: 'stripe',
        travelers: [travelerInfo],
      );

      final intent = await _services.paymentService
          .createStripeIntent(booking.bookingReference);

      // In production, use flutter_stripe to present payment sheet with intent.clientSecret
      // For now, poll payment status
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(
              bookingReference: booking.bookingReference,
              amount: intent.amount,
              currency: intent.currency,
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
                Column(
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
                Text('选择舱位等级',
                    style: context.textStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildClassSelector(),
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

  Widget _buildClassSelector() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_classLabels.length, (index) {
          final isSelected = _selectedClassIndex == index;
          final price =
              widget.train.prices[_classNames[index]]?.price;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedClassIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _classLabels[index],
                      style: context.textStyles.caption.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w500,
                        color: isSelected
                            ? context.colors.textMain
                            : context.colors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price != null ? '€${price.toStringAsFixed(0)}' : 'N/A',
                      style: context.textStyles.caption.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: context.colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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
                      color: context.colors.brandBlue.withOpacity(0.3),
                      style: BorderStyle.solid),
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
          color:
              isSelected ? context.colors.brandBlue.withOpacity(0.05) : context.colors.background,
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
            '${widget.train.origin.name} → ${widget.train.destination.name} (${_classLabels[_selectedClassIndex]})',
            '€${_selectedPrice.toStringAsFixed(2)}',
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
              Text('€${_selectedPrice.toStringAsFixed(2)}',
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
                        '支付 €${_selectedPrice.toStringAsFixed(2)}',
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
