import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildChatList(),
          _buildHeader(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(PhosphorIconsBold.arrowLeft, size: 20),
                  ),
                ),
                Column(
                  children: [
                    Text('FlipEarth 智能助理', style: AppTextStyles.h2.copyWith(fontSize: 17)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)), // emerald-500
                        const SizedBox(width: 4),
                        Text('在线', style: AppTextStyles.caption.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('正在转接人工...')));
                  },
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(PhosphorIconsBold.userCircleGear, size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 110, bottom: 150, left: 20, right: 20),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('今天 09:41', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
        ),
        _buildAssistantMessage(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMain, height: 1.5, fontWeight: FontWeight.w500),
              children: const [
                TextSpan(text: '您好杭先生！我是您的专属旅行助理。关于您下周伦敦到巴黎的 '),
                TextSpan(text: '#EST-9014-ABC', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' 订单，有什么我可以帮您的吗？'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildUserMessage('我想了解一下如果这趟车赶不上，能免费改签到下一班吗？'),
        const SizedBox(height: 24),
        _buildAssistantMessage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMain, height: 1.5, fontWeight: FontWeight.w500),
                  children: const [
                    TextSpan(text: '您购买的是 '),
                    TextSpan(text: 'Eurostar Standard', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' 席位。根据规定：'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('出发前均可免费改签（需补差价）'),
              const SizedBox(height: 8),
              _buildBulletPoint('一旦列车发车，该车票将作废，不支持顺延至下一班'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('立即办理改签', style: AppTextStyles.caption.copyWith(color: AppColors.brandBlue, fontWeight: FontWeight.bold)),
                      const Icon(PhosphorIconsBold.arrowRight, color: AppColors.brandBlue, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4, height: 4,
          margin: const EdgeInsets.only(top: 8, right: 8),
          decoration: const BoxDecoration(color: AppColors.brandBlue, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildAssistantMessage({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          margin: const EdgeInsets.only(top: 4, right: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.brandBlue, Color(0xFFA855F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: const Icon(PhosphorIconsFill.planet, color: Colors.white, size: 16),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: child,
          ),
        ),
        const SizedBox(width: 40), // Right spacing limit
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40), // Left spacing limit
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              boxShadow: [BoxShadow(color: AppColors.brandBlue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, height: 1.5, fontWeight: FontWeight.w500)),
          ),
        ),
        Container(
          width: 32, height: 32,
          margin: const EdgeInsets.only(top: 4, left: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionPill('修改乘车人'),
                      _buildActionPill('如何获取发票'),
                      _buildActionPill('行李额度'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: '输入您的问题...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMain, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(color: AppColors.brandBlue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Icon(PhosphorIconsBold.paperPlaneRight, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill(String text) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
