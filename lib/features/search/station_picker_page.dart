import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StationPickerPage extends StatefulWidget {
  const StationPickerPage({super.key});

  @override
  State<StationPickerPage> createState() => _StationPickerPageState();
}

class _StationPickerPageState extends State<StationPickerPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentStations = [
    '伦敦 St Pancras Int.',
    '巴黎 Gare du Nord',
    '阿姆斯特丹 Centraal',
  ];

  final List<Map<String, String>> _popularStations = [
    {'city': '伦敦', 'station': 'St Pancras Int.', 'flag': '🇬🇧'},
    {'city': '巴黎', 'station': 'Gare du Nord', 'flag': '🇫🇷'},
    {'city': '阿姆斯特丹', 'station': 'Centraal', 'flag': '🇳🇱'},
    {'city': '布鲁塞尔', 'station': 'Midi/Zuid', 'flag': '🇧🇪'},
    {'city': '里昂', 'station': 'Part Dieu', 'flag': '🇫🇷'},
    {'city': '日内瓦', 'station': 'Cornavin', 'flag': '🇨🇭'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectStation(String station) {
    Navigator.pop(context, station);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.x, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索城市或车站...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            border: InputBorder.none,
          ),
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          onChanged: (value) {
            // Setup simple local filter if needed in future
            setState(() {});
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderLight, height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_recentStations.isNotEmpty) ...[
          Text('最近搜索', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentStations.map((station) => _buildRecentChip(station)).toList(),
          ),
          const SizedBox(height: 32),
        ],
        Text('热门车站', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _buildPopularGrid(),
      ],
    );
  }

  Widget _buildRecentChip(String station) {
    return GestureDetector(
      onTap: () => _selectStation(station),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.clock, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(station, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularGrid() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _popularStations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final item = _popularStations[index];
        final fullName = '${item['city']} ${item['station']}';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(item['flag']!, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(item['city']!, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(item['station']!, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          onTap: () => _selectStation(fullName),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    // In a real app this would filter the station list actively.
    // Since this is UI building, we simply return a mock filtered list.
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(PhosphorIconsFill.mapPin, color: AppColors.brandBlue),
          title: Text('${_searchController.text} (模拟搜素结果)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text('所有车站', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          onTap: () => _selectStation(_searchController.text),
        ),
      ],
    );
  }
}
