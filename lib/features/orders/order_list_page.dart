import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../tickets/my_tickets_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildStickyTabBar(),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(),          // "全部订单"
                _buildEmptyState('暂无待支付订单'), // "待支付"
                _buildEmptyState('暂无已完成订单'), // "已完成"
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.centerLeft,
              child: const Icon(PhosphorIconsBold.arrowLeft, color: AppColors.textMain, size: 20),
            ),
          ),
          Expanded(
            child: Text(
              '订单中心',
              style: AppTextStyles.h2.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance the title to true center
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.borderLight, height: 1.0),
      ),
    );
  }

  Widget _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.brandBlue,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.brandBlue,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '全部订单'),
                  Tab(text: '待支付'),
                  Tab(text: '已完成'),
                ],
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        _buildActiveTrainTicketCard(),
        const SizedBox(height: 16),
        _buildInactiveItineraryCard(),
      ],
    );
  }

  Widget _buildActiveTrainTicketCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTicketsPage()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // Top Header Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.background)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.brandBlue.withOpacity(0.2)),
                        ),
                        child: Text(
                          '火车票',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2023-10-01 出发',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Text(
                    '已出票',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: Colors.green[600]),
                  ),
                ],
              ),
            ),
            // Bottom Content Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, AppColors.background.withOpacity(0.5)],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('伦敦', style: AppTextStyles.h1.copyWith(fontSize: 24, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text('St Pancras', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 11)),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(child: Container(color: AppColors.borderLight, height: 2)), // Dashed equivalent
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(PhosphorIconsFill.train, color: AppColors.brandBlue, size: 18),
                          ),
                          Expanded(child: Container(color: AppColors.borderLight, height: 2)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('巴黎', style: AppTextStyles.h1.copyWith(fontSize: 24, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text('Gare du Nord', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveItineraryCard() {
    return GestureDetector(
      onTap: () {},
      child: ColorFiltered(
        // Grayscale mode for inactive trip
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      0.7, 0, // 0.7 Opacity
        ]),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Top Header Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  border: const Border(bottom: BorderSide(color: AppColors.background)),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple.withOpacity(0.2)),
                          ),
                          child: Text(
                            '行程规划',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.purple[600],
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '2023-08-15 出发',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Text(
                      '已出行',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Bottom Content Row
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('瑞士绝美湖光山色 5 日游', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('包含 2 程火车票 · 3 晚酒店 · AI 行程单', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 65.0; // height of tab bar + divider
  @override
  double get maxExtent => 65.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
