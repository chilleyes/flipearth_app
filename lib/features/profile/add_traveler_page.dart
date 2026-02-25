import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/service_provider.dart';
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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedTitle = 'MR';
  String _selectedType = 'ADULT';
  DateTime? _dateOfBirth;
  bool _isDefault = false;
  bool _isSaving = false;
  String? _error;
  bool _isAttemptedSubmit = false;

  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
  }

  void _validateForm() {
    if (!_isAttemptedSubmit) return;
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    setState(() {
      _isFirstNameValid = first.isNotEmpty;
      _isLastNameValid = last.isNotEmpty;
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _isAttemptedSubmit = true);
    _validateForm();

    if (!_isFirstNameValid || !_isLastNameValid) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final data = <String, dynamic>{
        'firstName': _firstNameController.text.trim().toUpperCase(),
        'lastName': _lastNameController.text.trim().toUpperCase(),
        'title': _selectedTitle,
        'type': _selectedType,
        'isDefault': _isDefault,
      };

      if (_dateOfBirth != null) {
        data['dateOfBirth'] =
            '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}';
      }
      if (_emailController.text.isNotEmpty) {
        data['email'] = _emailController.text.trim();
      }
      if (_phoneController.text.isNotEmpty) {
        data['phone'] = _phoneController.text.trim();
      }
      if (_passportController.text.isNotEmpty) {
        data['passportNumber'] = _passportController.text.trim().toUpperCase();
      }

      await ServiceProvider().userService.addTraveler(data);

      if (mounted) {
        FocusScope.of(context).unfocus();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 120),
                  child: Column(
                    children: [
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_error!,
                              style: context.textStyles.caption
                                  .copyWith(color: Colors.red)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildSecurityNotice(),
                      const SizedBox(height: 24),
                      _buildTitleTypeSection(),
                      const SizedBox(height: 24),
                      _buildIdentitySection(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildDocumentSection(),
                      const SizedBox(height: 24),
                      _buildDefaultToggle(),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.borderLight),
              ),
              child: const Icon(PhosphorIconsBold.x, size: 18),
            ),
          ),
          Text('新增乘车人',
              style: context.textStyles.h2.copyWith(fontSize: 17)),
          const SizedBox(width: 40),
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
        border:
            Border.all(color: context.colors.brandBlue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(PhosphorIconsFill.shieldCheck,
                color: context.colors.brandBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '您的护照与个人信息将被安全加密存储，仅用于票务预订与海关申报验证。',
              style: context.textStyles.bodyMedium.copyWith(
                  color: context.colors.brandBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('称谓与类型',
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderLight),
          ),
          child: Column(
            children: [
              _buildDropdownRow('称谓', _selectedTitle,
                  ['MR', 'MRS', 'MS', 'MISS'], (v) {
                setState(() => _selectedTitle = v!);
              }),
              Divider(height: 1, color: context.colors.borderLight),
              _buildDropdownRow('乘客类型', _selectedType,
                  ['ADULT', 'YOUTH', 'CHILD', 'SENIOR'], (v) {
                setState(() => _selectedType = v!);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String value,
      List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(label,
                style: context.textStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(border: InputBorder.none),
              style: context.textStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
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
          child: Text('身份信息',
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: (!_isFirstNameValid || !_isLastNameValid)
                    ? Colors.red.shade300
                    : context.colors.borderLight),
          ),
          child: Column(
            children: [
              _buildInputRow(
                  label: '名 (First)',
                  placeholder: '如 HANG',
                  controller: _firstNameController,
                  isEnd: false,
                  isValid: _isFirstNameValid),
              _buildInputRow(
                  label: '姓 (Last)',
                  placeholder: '如 ZHAO',
                  controller: _lastNameController,
                  isEnd: false,
                  isValid: _isLastNameValid),
              SpringButton(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth ?? DateTime(1990, 1, 1),
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _dateOfBirth = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 85,
                        child: Text('出生日期',
                            style: context.textStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text(
                          _dateOfBirth != null
                              ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                              : '选择出生日期',
                          style: context.textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _dateOfBirth != null
                                ? context.colors.textMain
                                : context.colors.textMuted,
                          ),
                        ),
                      ),
                      Icon(PhosphorIconsBold.calendarBlank,
                          color: context.colors.textMuted, size: 18),
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

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('联系方式 (可选)',
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderLight),
          ),
          child: Column(
            children: [
              _buildInputRow(
                  label: '邮箱',
                  placeholder: 'email@example.com',
                  controller: _emailController,
                  isEnd: false,
                  isValid: true),
              _buildInputRow(
                  label: '手机号',
                  placeholder: '+86...',
                  controller: _phoneController,
                  isEnd: true,
                  isValid: true),
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
          child: Text('旅行证件 (可选)',
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderLight),
          ),
          child: _buildInputRow(
              label: '护照号',
              placeholder: '输入护照号码',
              controller: _passportController,
              isEnd: true,
              isValid: true),
        ),
      ],
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('设为默认乘车人',
              style: context.textStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          Switch(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            activeColor: context.colors.brandBlue,
          ),
        ],
      ),
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
        border: isEnd
            ? null
            : Border(
                bottom: BorderSide(color: context.colors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(label,
                style: context.textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isValid
                      ? context.colors.textMain
                      : Colors.red.shade700,
                )),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: context.textStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: context.textStyles.bodyMedium
                    .copyWith(color: context.colors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (!isValid)
            const Icon(PhosphorIconsFill.warningCircle,
                color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
            top: 24, bottom: 40, left: 24, right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.colors.background.withOpacity(0.95),
              context.colors.background.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.4, 0.7, 1.0],
          ),
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.textMain,
            foregroundColor: Colors.white,
            elevation: 10,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text('保存乘车人',
                  style: context.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16)),
        ),
      ),
    );
  }
}
