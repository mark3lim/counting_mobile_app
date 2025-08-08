import 'dart:ui';

import 'package:counting_app/data/model/category.dart';
import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 기본 카운팅 설정 화면을 표시하는 위젯입니다.
class BasicCountingSettingView extends StatefulWidget {
  // 기본 카운팅 설정 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/basic_counting_setting';

  final List<Category> categories;

  const BasicCountingSettingView({super.key, required this.categories});

  @override
  State<BasicCountingSettingView> createState() => _BasicCountingSettingViewState();
}

class _BasicCountingSettingViewState extends State<BasicCountingSettingView> {
  late TextEditingController _initialValueController;
  late TextEditingController _incrementValueController;
  late TextEditingController _nameController;
  bool _allowNegative = false;

  @override
  void initState() {
    super.initState();
    _initialValueController = TextEditingController(text: '0');
    _incrementValueController = TextEditingController(text: '1');
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _initialValueController.dispose();
    _incrementValueController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 기본 구조를 설정합니다.
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.detailSetting,
        onNextPressed: () {
          final settings = {
            'name': _nameController.text.trim(),
            'initialValue': int.tryParse(_initialValueController.text) ?? 0,
            'incrementStep': int.tryParse(_incrementValueController.text) ?? 1,
            'allowNegative': _allowNegative,
          };
          Navigator.of(context).pop(settings);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNameTextField(
              controller: _nameController,
              label: AppLocalizations.of(context)!.nameTitle,
            ),
            const SizedBox(height: 16),
            _buildToggleField(
              label: AppLocalizations.of(context)!.useNegativeNum,
              value: _allowNegative,
              onChanged: (value) {
                setState(() {
                  _allowNegative = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // 이름 설정 값을 입력받는 텍스트 필드를 생성합니다.
  Widget _buildNameTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Color(0xB2A0AFB7),
            borderRadius: BorderRadius.circular(20.0),
            border: null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none, // TextField 테두리 제거
                  ),
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 토글 스위치를 생성합니다.
  Widget _buildToggleField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xB2A0AFB7),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: Colors.blueAccent,
                activeColor: Colors.white,
                inactiveTrackColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}