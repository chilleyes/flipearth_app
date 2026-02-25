import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/traveler.dart';
import '../../core/providers/service_provider.dart';
import 'add_traveler_page.dart';

class TravelerListPage extends StatefulWidget {
  const TravelerListPage({super.key});

  @override
  State<TravelerListPage> createState() => _TravelerListPageState();
}

class _TravelerListPageState extends State<TravelerListPage> {
  final _userService = ServiceProvider().userService;
  List<Traveler> _travelers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTravelers();
  }

  Future<void> _loadTravelers() async {
    setState(() => _isLoading = true);
    try {
      final travelers = await _userService.getTravelers();
      if (mounted) {
        setState(() {
          _travelers = travelers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTraveler(Traveler t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除乘车人'),
        content: Text('确定要删除 ${t.fullName} 吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      await _userService.deleteTraveler(t.id);
      _loadTravelers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.arrowLeft,
              color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('常用乘车人',
            style: context.textStyles.h2.copyWith(fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsBold.plus,
                color: context.colors.brandBlue),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddTravelerPage()));
              _loadTravelers();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.colors.borderLight, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _travelers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsRegular.users,
                          size: 48, color: context.colors.textMuted),
                      const SizedBox(height: 16),
                      Text('暂无常用乘车人',
                          style: context.textStyles.bodyMedium
                              .copyWith(color: context.colors.textMuted)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AddTravelerPage()));
                          _loadTravelers();
                        },
                        icon: const Icon(PhosphorIconsBold.plus, size: 18),
                        label: const Text('添加乘车人'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _travelers.length,
                  itemBuilder: (context, index) {
                    final t = _travelers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: t.isDefault
                                ? context.colors.brandBlue
                                    .withOpacity(0.3)
                                : context.colors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: context.colors.brandBlue
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(t.initials,
                                style: context.textStyles.bodyMedium
                                    .copyWith(
                                        color: context.colors.brandBlue,
                                        fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(t.fullName,
                                        style: context
                                            .textStyles.bodyMedium
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.bold)),
                                    if (t.isDefault)
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 8),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1),
                                        decoration: BoxDecoration(
                                          color: context.colors.brandBlue
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('默认',
                                            style: context
                                                .textStyles.caption
                                                .copyWith(
                                                    color: context
                                                        .colors
                                                        .brandBlue,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 10)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${t.type} · ${t.title}${t.passportNumber != null ? ' · 护照 ${t.passportNumber}' : ''}',
                                  style: context.textStyles.caption
                                      .copyWith(
                                          color:
                                              context.colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _deleteTraveler(t),
                            child: Icon(PhosphorIconsBold.trash,
                                color: Colors.red[300], size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
