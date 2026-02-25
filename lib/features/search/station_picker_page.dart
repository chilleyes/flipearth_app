import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/station.dart';
import '../../core/providers/service_provider.dart';

class StationPickerPage extends StatefulWidget {
  const StationPickerPage({super.key});

  @override
  State<StationPickerPage> createState() => _StationPickerPageState();
}

class _StationPickerPageState extends State<StationPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  final _stationService = ServiceProvider().stationService;

  List<Station> _popularStations = [];
  List<Station> _searchResults = [];
  bool _isSearching = false;
  bool _loadingPopular = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPopularStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPopularStations() async {
    try {
      final stations = await _stationService.getPopular(limit: 12);
      if (mounted) setState(() {
        _popularStations = stations;
        _loadingPopular = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingPopular = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isSearching = true);
      try {
        final results = await _stationService.autocomplete(query, limit: 15);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _selectStation(Station station) {
    Navigator.pop(context, station);
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
          icon: Icon(PhosphorIconsBold.x, color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索城市或车站...',
            hintStyle: context.textStyles.bodyMedium
                .copyWith(color: context.colors.textMuted),
            border: InputBorder.none,
          ),
          style: context.textStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.bold),
          onChanged: _onSearchChanged,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child:
              Container(color: context.colors.borderLight, height: 1.0),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.length >= 2) {
      return _buildSearchResults();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('热门车站', style: context.textStyles.h3),
        const SizedBox(height: 12),
        if (_loadingPopular)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ))
        else
          _buildPopularGrid(),
      ],
    );
  }

  Widget _buildPopularGrid() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _popularStations.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: context.colors.borderLight),
      itemBuilder: (context, index) {
        final station = _popularStations[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.brandBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(station.flag, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(station.city ?? station.name,
              style: context.textStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(station.name,
              style: context.textStyles.caption
                  .copyWith(color: context.colors.textMuted)),
          trailing: station.isEurostarDirect == true
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.brandBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('直达',
                      style: context.textStyles.caption.copyWith(
                          color: context.colors.brandBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                )
              : null,
          onTap: () => _selectStation(station),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            '未找到匹配的车站',
            style: context.textStyles.bodyMedium
                .copyWith(color: context.colors.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: context.colors.borderLight),
      itemBuilder: (context, index) {
        final station = _searchResults[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(PhosphorIconsFill.mapPin, color: context.colors.brandBlue),
          title: Text(station.displayName ?? station.name,
              style: context.textStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          subtitle: station.city != null
              ? Text('${station.city}, ${station.countryCode ?? ''}',
                  style: context.textStyles.caption
                      .copyWith(color: context.colors.textMuted))
              : null,
          onTap: () => _selectStation(station),
        );
      },
    );
  }
}
