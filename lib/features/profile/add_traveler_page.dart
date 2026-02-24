import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../booking/widgets/checkout_sheet.dart';
import '../booking/seat_selection_page.dart';
import '../../core/widgets/spring_button.dart';

class AddTravelerPage extends StatefulWidget {
  const AddTravelerPage({super.key});

  @override
  State<AddTravelerPage> createState() => _AddTravelerPageState();
}

class _AddTravelerPageState extends State<AddTravelerPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passportController = TextEditingController();
  String _selectedSeat = '选座偏好 (可选)';
  
  // Validation State
  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;
  bool _isPassportValid = true;
  bool _isAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _passportController.addListener(_validateForm);
  }

  void _validateForm() {
    if (!_isAttemptedSubmit) return;

    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final pp = _passportController.text.trim();

    // Standard western/pinyin name (letters only, min 1 char)
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    // Typical passport structure (letters and numbers, min 6 chars)
    final ppRegex = RegExp(r'^[A-Z0-9]{6,15}$');

    setState(() {
      _isFirstNameValid = first.isNotEmpty && nameRegex.hasMatch(first);
      _isLastNameValid = last.isNotEmpty && nameRegex.hasMatch(last);
      _isPassportValid = pp.isNotEmpty && ppRegex.hasMatch(pp);
    });
  }

  bool _isFormValid() {
    return _isFirstNameValid && _isLastNameValid && _isPassportValid &&
           _firstNameController.text.isNotEmpty &&
           _lastNameController.text.isNotEmpty &&
           _passportController.text.isNotEmpty;
  }

  void _handleSubmit() {
    setState(() => _isAttemptedSubmit = true);
    _validateForm();
    
    if (_isFormValid()) {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
      
      // Pop the specific AddTravelerPage from navigation stack
      Navigator.pop(context);
      
      // Show the Checkout Sheet on top of the underlying Booking flow
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CheckoutSheet(),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
                  child: Column(
                    children: [
                      _buildSecurityNotice(),
                      const SizedBox(height: 24),
                      _buildIdentitySection(),
                      const SizedBox(height: 24),
                      _buildDocumentSection(),
                      const SizedBox(height: 24),
                      _buildSeatSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.borderLight),
              ),
              child: const Icon(PhosphorIconsBold.x, size: 18),
            ),
          ),
          Text('新增乘车人', style: context.textStyles.h2.copyWith(fontSize: 17)),
          const SizedBox(width: 40), // Balance
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.brandBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.brandBlue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(PhosphorIconsFill.shieldCheck, color: context.colors.brandBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '您的护照与个人信息将被安全加密存储，仅用于票务预订与海关申报验证。',
              style: context.textStyles.bodyMedium.copyWith(color: context.colors.brandBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('身份信息', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (!_isFirstNameValid || !_isLastNameValid) ? Colors.red.shade300 : context.colors.borderLight),
            boxShadow: [
              if (!_isFirstNameValid || !_isLastNameValid)
                BoxShadow(color: Colors.red.shade100, blurRadius: 4, spreadRadius: 1)
              else
                const BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Column(
            children: [
              _buildInputRow(
                label: '名 (First)', placeholder: '如 HANG', controller: _firstNameController, isEnd: false, isValid: _isFirstNameValid
              ),
              _buildInputRow(
                label: '姓 (Last)', placeholder: '如 ZHAO', controller: _lastNameController, isEnd: false, isValid: _isLastNameValid
              ),
              _buildSelectorRow(label: '出生日期', value: 'YYYY-MM-DD', icon: PhosphorIconsBold.calendarBlank, isEnd: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('旅行证件', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: !_isPassportValid ? Colors.red.shade300 : context.colors.borderLight),
            boxShadow: [
              if (!_isPassportValid)
                BoxShadow(color: Colors.red.shade100, blurRadius: 4, spreadRadius: 1)
              else
                const BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Column(
            children: [
              _buildSelectorRow(label: '发行国家', value: '中国 (CHINA)', icon: PhosphorIconsBold.caretRight, isEnd: false),
              _buildInputRow(
                label: '护照号', placeholder: '输入护照号码', controller: _passportController, isEnd: false, isValid: _isPassportValid
              ),
              _buildSelectorRow(label: '有效期至', value: 'YYYY-MM-DD', icon: PhosphorIconsBold.calendarBlank, isEnd: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('座位服务', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderLight),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: SpringButton(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeatSelectionPage()),
              );
              if (result != null && result is String) {
                setState(() => _selectedSeat = result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                 SizedBox(
                    width: 85,
                    child: Text('选择座位', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                 ),
                 Expanded(
                    child: Text(
                      _selectedSeat,
                      style: context.textStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedSeat.contains('可选') ? context.colors.textMuted : context.colors.brandBlue,
                      ),
                    ),
                  ),
                  Icon(PhosphorIconsFill.armchair, color: context.colors.brandBlue, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool isEnd,
    required bool isValid,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isValid ? Colors.transparent : Colors.red.withOpacity(0.02),
        border: isEnd ? null : Border(bottom: BorderSide(color: context.colors.borderLight))
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label, 
              style: context.textStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isValid ? context.colors.textMain : Colors.red.shade700,
              )
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (!isValid)
            const Icon(PhosphorIconsFill.warningCircle, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildSelectorRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isEnd,
  }) {
    return SpringButton(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(border: isEnd ? null : Border(bottom: BorderSide(color: context.colors.borderLight))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 85,
              child: Text(label, style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(
                value,
                style: context.textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: value.contains('YYYY') ? context.colors.textMuted : context.colors.textMain,
                ),
              ),
            ),
            Icon(icon, color: context.colors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 40, left: 24, right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [context.colors.background.withOpacity(0.95), context.colors.background.withOpacity(0.8), Colors.transparent],
            stops: const [0.4, 0.7, 1.0],
          ),
        ),
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.textMain,
            foregroundColor: Colors.white,
            elevation: 10,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text('保存乘车人', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
