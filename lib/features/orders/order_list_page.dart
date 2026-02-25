import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/order.dart';
import '../../core/providers/service_provider.dart';
import 'order_detail_page.dart';
import '../itinerary/itinerary_detail_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _orderService = ServiceProvider().orderService;

  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  Pagination? _pagination;
  String? _currentType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadOrders(tabIndex: _tabController.index);
      }
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({int tabIndex = 0, int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    String? type;
    String? status;
    switch (tabIndex) {
      case 1:
        status = 'created';
        break;
      case 2:
        status = 'completed';
        break;
    }

    try {
      final result = await _orderService.getOrders(
          type: type, status: status, page: page);
      if (mounted) {
        setState(() {
          _orders = result.items;
          _pagination = result.pagination;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildStickyTabBar(),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContent(),
                _buildContent(),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsFill.warningCircle,
                size: 48, color: context.colors.textMuted),
            const SizedBox(height: 16),
            Text('加载失败', style: context.textStyles.bodyMedium),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadOrders(tabIndex: _tabController.index),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Text('暂无订单',
            style: context.textStyles.bodyMedium
                .copyWith(color: context.colors.textMuted)),
      );
    }
    return _buildOrderList();
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
              child: Icon(PhosphorIconsBold.arrowLeft,
                  color: context.colors.textMain, size: 20),
            ),
          ),
          Expanded(
            child: Text('订单中心',
                style: context.textStyles.h2.copyWith(fontSize: 17),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 40),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: context.colors.borderLight, height: 1.0),
      ),
    );
  }

  Widget _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        child: Container(
          color: context.colors.background,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: context.colors.brandBlue,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: context.colors.brandBlue,
                unselectedLabelColor: context.colors.textMuted,
                labelStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '全部订单'),
                  Tab(text: '待支付'),
                  Tab(text: '已完成'),
                ],
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colors.borderLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: order.isTrain
              ? _buildTrainOrderCard(order)
              : _buildItineraryCard(order),
        );
      },
    );
  }

  Widget _buildTrainOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        if (order.bookingReference != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailPage(bookingRef: order.bookingReference!),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.borderLight),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: context.colors.background)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.brandBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: context.colors.brandBlue
                                  .withOpacity(0.2)),
                        ),
                        child: Text('火车票',
                            style: context.textStyles.caption.copyWith(
                                color: context.colors.brandBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.departureTime?.split(' ').first ??
                            order.createdAt ?? '',
                        style: context.textStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.textMuted),
                      ),
                    ],
                  ),
                  Text(
                    order.statusLabel ?? order.status,
                    style: context.textStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _statusColor(order.status)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.origin ?? '',
                          style: context.textStyles.h1
                              .copyWith(fontSize: 20, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text(order.trainNumber ?? '',
                          style: context.textStyles.caption.copyWith(
                              color: context.colors.textMuted,
                              fontSize: 11)),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                  color: context.colors.borderLight,
                                  height: 2)),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: context.colors.borderLight),
                            ),
                            alignment: Alignment.center,
                            child: Icon(PhosphorIconsFill.train,
                                color: context.colors.brandBlue, size: 18),
                          ),
                          Expanded(
                              child: Container(
                                  color: context.colors.borderLight,
                                  height: 2)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(order.destination ?? '',
                          style: context.textStyles.h1
                              .copyWith(fontSize: 20, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      if (order.price != null)
                        Text(
                            '€${order.price!.toStringAsFixed(2)}',
                            style: context.textStyles.caption.copyWith(
                                color: context.colors.brandBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
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

  Widget _buildItineraryCard(Order order) {
    return GestureDetector(
      onTap: () {
        if (order.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItineraryDetailPage(itineraryId: order.id!),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: context.colors.background)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('行程规划',
                            style: context.textStyles.caption.copyWith(
                                color: Colors.purple[600],
                                fontWeight: FontWeight.w900,
                                fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      Text(order.startDate ?? '',
                          style: context.textStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.city ?? ''} ${order.days ?? 0} 日游',
                    style: context.textStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.startDate ?? ''} ~ ${order.endDate ?? ''}',
                    style: context.textStyles.caption.copyWith(
                        color: context.colors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
      case '4':
      case 'completed':
        return Colors.green[600]!;
      case 'created':
      case 'PREBOOKED':
        return Colors.orange;
      case 'refunded':
      case 'cancelled':
        return Colors.grey;
      default:
        return context.colors.textMuted;
    }
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 65.0;
  @override
  double get maxExtent => 65.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
