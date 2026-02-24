import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/spring_button.dart';
import '../profile/add_traveler_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Mock currently selected date index
  int _selectedDateIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildTrainList(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent, // It handles the color via flexibleSpace
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 180,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: context.colors.textMain.withOpacity(0.95), // dark glass equivalent
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Top Title Row
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
                            Text('London', style: context.textStyles.h2.copyWith(color: Colors.white, fontSize: 18)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(PhosphorIconsBold.arrowRight, color: context.colors.brandBlue, size: 14),
                            ),
                            Text('Paris', style: context.textStyles.h2.copyWith(color: Colors.white, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '10 OCT',
                              style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                            Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(color: context.colors.textMuted, shape: BoxShape.circle),
                            ),
                            Text(
                              '1 ADULT',
                              style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
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
                // Horizontal Date Selector
                SizedBox(
                  height: 65,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final dates = ['Tue 9', 'Wed 10', 'Thu 11', 'Fri 12'];
                      final prices = ['€75', '€55', '€55', '€89'];
                      final isSelected = index == _selectedDateIndex;
                      return _buildDateCard(
                        date: dates[index],
                        price: prices[index],
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedDateIndex = index),
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
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onTap}) {
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
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SpringButton(
      onTap: onTap,
      child: Container(
        width: 65,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.brandBlue : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(color: context.colors.brandBlue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date.toUpperCase(),
                  style: context.textStyles.caption.copyWith(
                    color: isSelected ? Colors.white : context.colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399), // emerald-400
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.textMain, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainList() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildTrainCard(
            departureTime: '09:31',
            departureStation: 'London St Pancras',
            arrivalTime: '12:47',
            arrivalStation: 'Paris Gare du Nord',
            price: '€55',
            duration: '2h 16m',
            trainNumber: 'EST 9014 (直达)',
            isFastest: true,
            hasSufficientTickets: true,
          ),
          const SizedBox(height: 16),
          _buildTrainCard(
            departureTime: '10:31',
            departureStation: 'London St Pancras',
            arrivalTime: '13:47',
            arrivalStation: 'Paris Gare du Nord',
            price: '€78',
            duration: '2h 16m',
            trainNumber: 'EST 9016 (直达)',
            isFastest: false,
            hasSufficientTickets: false,
          ),
        ]),
      ),
    );
  }

  Widget _buildTrainCard({
    required String departureTime,
    required String departureStation,
    required String arrivalTime,
    required String arrivalStation,
    required String price,
    required String duration,
    required String trainNumber,
    required bool isFastest,
    required bool hasSufficientTickets,
  }) {
    return SpringButton(
      onTap: () {
        _showCheckoutBottomSheet(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFastest ? context.colors.brandBlue.withOpacity(0.3) : context.colors.borderLight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (isFastest)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.brandBlue.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsFill.lightning, color: context.colors.brandBlue, size: 12),
                      const SizedBox(width: 4),
                      Text('最快到达', style: context.textStyles.caption.copyWith(color: context.colors.brandBlue, fontWeight: FontWeight.bold, fontSize: 10)),
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
                      // Times and Stations
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildTimeRow(departureTime, departureStation, isStart: true),
                            const SizedBox(height: 16),
                            _buildTimeRow(arrivalTime, arrivalStation, isStart: false),
                          ],
                        ),
                      ),
                      // Divider
                      Container(width: 1, height: 60, color: context.colors.borderLight),
                      // Price Column
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('STANDARD起', style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text(price, style: context.textStyles.h1.copyWith(fontSize: 32, letterSpacing: -1.0)),
                            if (hasSufficientTickets) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)), // emerald-50
                                child: Text('余票充足', style: context.textStyles.caption.copyWith(color: const Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 10)),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Footer Info 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      border: Border.all(color: context.colors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.clock, color: context.colors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Text(duration, style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 11)),
                        Container(
                          width: 4, height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: context.colors.textMuted, shape: BoxShape.circle),
                        ),
                        Icon(PhosphorIconsFill.train, color: context.colors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Text(trainNumber, style: context.textStyles.caption.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 11)),
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

  Widget _buildTimeRow(String time, String station, {required bool isStart}) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(time, style: context.textStyles.h2.copyWith(fontSize: 22, letterSpacing: -0.5)),
        ),
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isStart ? context.colors.textMain : context.colors.brandBlue, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(station, style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showCheckoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _CheckoutBottomSheet();
      },
    );
  }
}

class _CheckoutBottomSheet extends StatefulWidget {
  const _CheckoutBottomSheet();

  @override
  State<_CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<_CheckoutBottomSheet> {
  int _selectedClassIndex = 0;
  final List<Map<String, dynamic>> _classes = [
    {'name': 'Standard', 'price': 55},
    {'name': 'Premier', 'price': 120},
    {'name': 'Business', 'price': 250},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 50, offset: Offset(0, -20)),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48, height: 6,
              decoration: BoxDecoration(color: context.colors.borderLight, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('确认订单', style: context.textStyles.h1.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text('09:31 出发 · 伦敦至巴黎', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(PhosphorIconsBold.x, size: 16, color: context.colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Class Selector
                Text('选择舱位等级', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(_classes.length, (index) {
                      final isSelected = _selectedClassIndex == index;
                      final ticketClass = _classes[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedClassIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected ? [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                              ] : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ticketClass['name']!,
                                  style: context.textStyles.caption.copyWith(
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                                    color: isSelected ? context.colors.textMain : context.colors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '€${ticketClass['price']}',
                                  style: context.textStyles.caption.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                ),
                const SizedBox(height: 24),
                
                // Traveler Info
                Container(
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
                          Text('乘车人信息', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTravelerPage())),
                            child: Row(
                              children: [
                                Icon(PhosphorIconsBold.plus, color: context.colors.brandBlue, size: 14),
                                const SizedBox(width: 4),
                                Text('管理乘车人', style: context.textStyles.caption.copyWith(color: context.colors.brandBlue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.colors.borderLight)),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: context.colors.brandBlue.withOpacity(0.1), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text('ZH', style: context.textStyles.bodyMedium.copyWith(color: context.colors.brandBlue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ZHAO / HANG', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('护照: E1234****', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
                                ],
                              ),
                            ),
                            const Icon(PhosphorIconsFill.checkCircle, color: Color(0xFF10B981), size: 24), // emerald-500
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price Breakdown Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('欧洲之星成人票 (${_classes[_selectedClassIndex]['name']})', '€${_classes[_selectedClassIndex]['price']}.00'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('税费及服务费', '€0.00'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: context.colors.borderLight, height: 1, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('总价', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('€${_classes[_selectedClassIndex]['price']}.00', style: context.textStyles.h1.copyWith(fontSize: 24)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Sticky Footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: context.colors.borderLight)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16, height: 16,
                      margin: const EdgeInsets.only(top: 2, right: 10),
                      decoration: BoxDecoration(color: context.colors.textMain, borderRadius: BorderRadius.circular(4)),
                      child: const Icon(PhosphorIconsBold.check, color: Colors.white, size: 12),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w500),
                          children: [
                            const TextSpan(text: '购票即代表您同意 '),
                            TextSpan(text: '退改签政策', style: TextStyle(color: context.colors.brandBlue, decoration: TextDecoration.underline)),
                            const TextSpan(text: ' 及 '),
                            TextSpan(text: '服务条款', style: TextStyle(color: context.colors.brandBlue, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Navigate to Success Page or execute Payment
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black, // Apple Pay black
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIconsFill.appleLogo, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text('Pay €${_classes[_selectedClassIndex]['price']}.00', style: context.textStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textStyles.caption.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13)),
        Text(value, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
