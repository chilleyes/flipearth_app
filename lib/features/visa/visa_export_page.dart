import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/trip.dart';
import '../../core/models/visa_export.dart';
import '../../core/providers/service_provider.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class VisaExportPage extends StatefulWidget {
  final int tripId;

  const VisaExportPage({super.key, required this.tripId});

  @override
  State<VisaExportPage> createState() => _VisaExportPageState();
}

class _VisaExportPageState extends State<VisaExportPage> {
  final _sp = ServiceProvider();
  final _formKey = GlobalKey<FormState>();

  // Trip data
  TripDetail? _trip;
  bool _isLoadingTrip = true;
  String? _loadError;

  // Form fields
  final _nameCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // Per-stay accommodation controllers: stayId -> (name, address)
  final Map<int, TextEditingController> _hotelNameCtrls = {};
  final Map<int, TextEditingController> _hotelAddrCtrls = {};

  // Submission state
  bool _isSubmitting = false;
  VisaExportResult? _exportResult;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passportCtrl.dispose();
    _countryCtrl.dispose();
    for (final c in _hotelNameCtrls.values) {
      c.dispose();
    }
    for (final c in _hotelAddrCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTrip() async {
    try {
      final trip = await _sp.tripService.getTripDetail(widget.tripId);
      if (!mounted) return;
      setState(() {
        _trip = trip;
        _isLoadingTrip = false;
        for (final stay in trip.stays) {
          _hotelNameCtrls[stay.id] = TextEditingController(text: stay.accommodationName ?? '');
          _hotelAddrCtrls[stay.id] = TextEditingController();
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = ApiClient.getErrorMessage(e);
        _isLoadingTrip = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final accommodations = <Map<String, dynamic>>[];
    for (final stay in _trip!.stays) {
      final name = _hotelNameCtrls[stay.id]?.text.trim() ?? '';
      final addr = _hotelAddrCtrls[stay.id]?.text.trim() ?? '';
      if (name.isNotEmpty) {
        accommodations.add({
          'stay_id': stay.id,
          'name': name,
          'address': addr,
        });
      }
    }

    final draft = VisaExportDraft(
      travelerName: _nameCtrl.text.trim(),
      passportNo: _passportCtrl.text.trim(),
      applicationCountry: _countryCtrl.text.trim(),
      accommodations: accommodations
          .map((a) => AccommodationInfo.fromJson(a))
          .toList(),
    );

    try {
      final result = await _sp.visaService.createExport(widget.tripId, draft.toJson());
      if (!mounted) return;
      setState(() {
        _exportResult = result;
        _isSubmitting = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.getErrorMessage(e))),
      );
    }
  }

  Future<void> _openPdf() async {
    if (_exportResult == null) return;
    final url = _sp.visaService.getDownloadUrl(_exportResult!.id);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开下载链接')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('签证行程单', style: textStyles.h3.copyWith(color: colors.textMain)),
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingTrip
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _loadError != null
              ? _buildLoadError(colors, textStyles)
              : _exportResult != null
                  ? _buildSuccess(colors, textStyles)
                  : _buildForm(colors, textStyles),
    );
  }

  // ──────────────── Error state ────────────────

  Widget _buildLoadError(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.warning(), size: 48, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(_loadError!, style: textStyles.bodyMedium.copyWith(color: colors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoadingTrip = true;
                  _loadError = null;
                });
                _loadTrip();
              },
              child: Text('重试', style: textStyles.bodyMedium.copyWith(color: colors.brandBlue)),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Form ────────────────

  Widget _buildForm(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final stays = List<TripStay>.from(_trip!.stays)..sort((a, b) => a.stayOrder.compareTo(b.stayOrder));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          // Section: Traveler info
          _SectionHeader(title: '旅客信息', icon: PhosphorIcons.user(), colors: colors, textStyles: textStyles),
          const SizedBox(height: 12),
          _buildTextField(label: '姓名（与护照一致）', ctrl: _nameCtrl, colors: colors, textStyles: textStyles, validator: _required),
          const SizedBox(height: 12),
          _buildTextField(label: '护照号码', ctrl: _passportCtrl, colors: colors, textStyles: textStyles, validator: _required),
          const SizedBox(height: 12),
          _buildTextField(label: '签证申请国', ctrl: _countryCtrl, colors: colors, textStyles: textStyles, validator: _required),

          const SizedBox(height: 32),

          // Section: Accommodations
          _SectionHeader(title: '住宿信息', icon: PhosphorIcons.buildings(), colors: colors, textStyles: textStyles),
          const SizedBox(height: 4),
          Text('请为每个城市停留补充住宿信息（已有住宿的将自动带入）', style: textStyles.bodySmall.copyWith(color: colors.textMuted)),
          const SizedBox(height: 16),

          ...stays.map((stay) => _buildStayAccommodation(stay, colors, textStyles)),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandBlue,
                disabledBackgroundColor: colors.brandBlue.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.filePdf(), size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text('Generate PDF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayAccommodation(TripStay stay, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    final dateFormat = DateFormat('MMM d');
    final hasExisting = stay.accommodationName != null && stay.accommodationName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), size: 18, color: colors.brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${stay.city}${stay.country != null ? ', ${stay.country}' : ''}',
                  style: textStyles.bodyLarge,
                ),
              ),
              Text(
                '${stay.nights} 晚',
                style: textStyles.caption.copyWith(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${dateFormat.format(stay.checkInDate)} — ${dateFormat.format(stay.checkOutDate)}',
            style: textStyles.bodySmall.copyWith(color: colors.textMuted),
          ),
          if (hasExisting) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.successGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.checkCircle(), size: 14, color: colors.successGreen),
                  const SizedBox(width: 4),
                  Text('已有住宿', style: textStyles.caption.copyWith(color: colors.successGreen, fontSize: 10)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildTextField(
            label: '酒店/住宿名称',
            ctrl: _hotelNameCtrls[stay.id]!,
            colors: colors,
            textStyles: textStyles,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: '住宿地址',
            ctrl: _hotelAddrCtrls[stay.id]!,
            colors: colors,
            textStyles: textStyles,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController ctrl,
    required AppColorsExtension colors,
    required AppTextStylesExtension textStyles,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      style: textStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textStyles.bodySmall.copyWith(color: colors.textMuted),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.brandBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? '此项为必填' : null;

  // ──────────────── Success state ────────────────

  Widget _buildSuccess(AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 52, color: colors.successGreen),
            ),
            const SizedBox(height: 24),
            Text('行程单已生成', style: textStyles.h2),
            const SizedBox(height: 8),
            Text(
              '签证行程单 PDF 已准备就绪',
              style: textStyles.bodyMedium.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 12),

            // Export info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.borderLight),
              ),
              child: Column(
                children: [
                  _infoRow('旅客', _exportResult!.travelerName, colors, textStyles),
                  Divider(height: 20, color: colors.borderLight),
                  _infoRow('护照号', _exportResult!.passportNo, colors, textStyles),
                  Divider(height: 20, color: colors.borderLight),
                  _infoRow('申请国', _exportResult!.applicationCountry, colors, textStyles),
                  Divider(height: 20, color: colors.borderLight),
                  _infoRow('状态', _exportResult!.status == 'ready' ? '已就绪' : _exportResult!.status, colors, textStyles),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Download button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _openPdf,
                icon: const Icon(PhosphorIconsBold.downloadSimple, color: Colors.white, size: 20),
                label: const Text('Download / Preview PDF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('返回行程', style: textStyles.bodyMedium.copyWith(color: colors.textMuted, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, AppColorsExtension colors, AppTextStylesExtension textStyles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyles.bodySmall.copyWith(color: colors.textMuted)),
        Text(value, style: textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppColorsExtension colors;
  final AppTextStylesExtension textStyles;

  const _SectionHeader({required this.title, required this.icon, required this.colors, required this.textStyles});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.brandBlue),
        const SizedBox(width: 8),
        Text(title, style: textStyles.h3.copyWith(color: colors.textMain)),
      ],
    );
  }
}
