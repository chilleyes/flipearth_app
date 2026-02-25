import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../orders/order_list_page.dart';
import '../chat/chat_page.dart';
import 'traveler_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(auth),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      if (!auth.isLoggedIn)
                        _buildLoginPrompt()
                      else ...[
                        _buildSettingsCard(context),
                        const SizedBox(height: 24),
                        _buildLogoutButton(auth),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AuthProvider auth) {
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
              padding:
                  const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          context.colors.brandBlue,
                          const Color(0xFF38BDF8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: auth.isLoggedIn
                          ? Text(
                              auth.user!.username.isNotEmpty
                                  ? auth.user!.username[0].toUpperCase()
                                  : 'U',
                              style: context.textStyles.h1.copyWith(
                                  color: context.colors.brandBlue,
                                  fontSize: 28),
                            )
                          : Icon(PhosphorIconsFill.user,
                              color: context.colors.brandBlue, size: 32),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isLoggedIn
                            ? auth.user!.username
                            : '未登录',
                        style:
                            context.textStyles.h1.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      if (auth.isLoggedIn)
                        Text(
                          auth.user!.email,
                          style: context.textStyles.caption.copyWith(
                              color: context.colors.textMuted),
                        ),
                      if (auth.isLoggedIn && auth.user!.isWhite == 1)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.brandBlue
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRO 会员',
                            style: context.textStyles.caption.copyWith(
                              color: context.colors.brandBlue,
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
        child: Container(color: context.colors.borderLight, height: 1),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        children: [
          Icon(PhosphorIconsFill.userCircle,
              size: 64, color: context.colors.textMuted),
          const SizedBox(height: 16),
          Text('登录后可享受完整功能',
              style: context.textStyles.bodyMedium
                  .copyWith(color: context.colors.textMuted)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('登录 / 注册',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderLight),
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
            iconColor: context.colors.brandBlue,
            iconBgColor: const Color(0xFFEFF6FF),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatPage()));
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '订单中心',
            subtitle: '历史行程与车票',
            icon: PhosphorIconsFill.ticket,
            iconColor: context.colors.brandBlue,
            iconBgColor: const Color(0xFFEFF6FF),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OrderListPage()));
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '常用乘车人',
            subtitle: '管理护照与联系方式',
            icon: PhosphorIconsFill.users,
            iconColor: const Color(0xFF059669),
            iconBgColor: const Color(0xFFECFDF5),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TravelerListPage()));
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            title: '语言与货币设定',
            subtitle: '中文 · EUR (€)',
            icon: PhosphorIconsFill.translate,
            iconColor: const Color(0xFFF97316),
            iconBgColor: const Color(0xFFFFF7ED),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: context.textStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(subtitle,
            style: context.textStyles.caption
                .copyWith(color: context.colors.textMuted)),
      ),
      trailing: Icon(PhosphorIconsBold.caretRight,
          color: context.colors.borderLight, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        thickness: 1,
        color: context.colors.background,
        indent: 76);
  }

  Widget _buildLogoutButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await auth.logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: context.colors.borderLight),
          ),
        ),
        child: const Text(
          '退出登录',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
