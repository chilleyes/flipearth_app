import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../orders/order_list_page.dart';
import '../chat/chat_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildSettingsCard(context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: 180,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Row(
                children: [
                  // Gradient Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.brandBlue, Color(0xFF38BDF8)], // sky-400
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x19000000), // shadow-sm
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3), // p-[3px] equivalent
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // User Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hang Zhao',
                        style: AppTextStyles.h1.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRO 会员',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderLight,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            title: '我的客服',
            subtitle: '在线支持与反馈',
            icon: PhosphorIconsFill.headset,
            iconColor: AppColors.brandBlue,
            iconBgColor: const Color(0xFFEFF6FF),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '订单中心',
            subtitle: '历史行程与车票',
            icon: PhosphorIconsFill.ticket,
            iconColor: AppColors.brandBlue,
            iconBgColor: const Color(0xFFEFF6FF), // blue-50
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderListPage()));
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '常用乘车人',
            subtitle: '管理护照与联系方式',
            icon: PhosphorIconsFill.users,
            iconColor: const Color(0xFF059669), // emerald-600
            iconBgColor: const Color(0xFFECFDF5), // emerald-50
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '语言与货币设定',
            subtitle: '中文 · EUR (€)',
            icon: PhosphorIconsFill.translate,
            iconColor: const Color(0xFFF97316), // orange-500
            iconBgColor: const Color(0xFFFFF7ED), // orange-50
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '智能客服',
            subtitle: '遇到问题？联系我们',
            icon: PhosphorIconsFill.headset,
            iconColor: const Color(0xFF9333EA), // purple-600
            iconBgColor: const Color(0xFFFAF5FF), // purple-50
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
      ),
      trailing: const Icon(PhosphorIconsBold.caretRight, color: AppColors.borderLight, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.background,
      indent: 76,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: const Text(
          '退出登录',
          style: TextStyle(
            color: Color(0xFFEF4444), // red-500
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
