import 'dart:ui';

import 'package:counting_app/data/model/category.dart';
import 'package:counting_app/data/model/category_list.dart';
import 'package:counting_app/data/repositories/counting_repository.dart';
import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/widgets/custom_app_save_bar.dart';
import 'package:counting_app/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 기본 카운팅에 대한 세부 설정을 하는 화면 위젯입니다.
class BasicCountingSettingView extends StatefulWidget {
  // 기본 카운팅 설정 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/basic_counting_setting';

  final List<Category> categories;

  const BasicCountingSettingView({super.key, required this.categories});

  @override
  State<BasicCountingSettingView> createState() => _BasicCountingSettingViewState();
}

class _BasicCountingSettingViewState extends State<BasicCountingSettingView> {
  late TextEditingController _nameController;
  late final CountingRepository _repository;
  bool _allowNegative = false;
  bool _isHidden = false;
  bool _isSaving = false;

  @override
  void initState() {
    // 위젯의 상태를 초기화합니다.
    super.initState();
    _nameController = TextEditingController();
    _repository = CountingRepository();
  }

  @override
  void dispose() {
    // 컨트롤러 리소스를 해제하여 메모리 누수를 방지합니다.
    _nameController.dispose();
    super.dispose();
  }

  // 저장 버튼을 눌렀을 때 호출되는 함수입니다.
  void _onSave() async {
    if (_isSaving) return; // 재진입 방지

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
      );
      return;
    }

    FocusScope.of(context).unfocus(); // 키보드 내리기

    setState(() {
      _isSaving = true;
    });

    try {
      final newCategoryList = CategoryList(
        name: name,
        categoryList: List.unmodifiable(widget.categories),
        modifyDate: DateTime.now(),
        useNegativeNum: _allowNegative,
        isHidden: _isHidden,
        categoryType: 'basic',
      );

      await _repository.addCategoryList(newCategoryList);

      if (mounted) {
        // 저장 후 화면 스택을 모두 지우고 홈 화면으로 이동합니다.
        Navigator.of(context).pushNamedAndRemoveUntil(HomeView.routeName, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailedMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 기본 UI 구조를 빌드합니다.
    return Scaffold(
      appBar: CustomAppSaveBar(
        title: AppLocalizations.of(context)!.detailSetting,
        onSavePressed: _isSaving ? null : _onSave,
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
              bottomRadius: 0.0,
            ),
            _buildToggleField(
              label: AppLocalizations.of(context)!.hideToggle,
              value: _isHidden,
              onChanged: (value) {
                setState(() {
                  _isHidden = value;
                });
              },
              topRadius: 0.0,
            ),
          ],
        ),
      ),
    );
  }

  // 이름 입력을 위한 텍스트 필드 위젯을 생성합니다.
  Widget _buildNameTextField({
    required TextEditingController controller,
    required String label,
    double topRadius = 20.0,
    double bottomRadius = 20.0,
  }) {
    // 유리 효과가 적용된 컨테이너 안에 텍스트 필드를 배치합니다.
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: Radius.circular(bottomRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xB2A0AFB7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: Radius.circular(bottomRadius)),
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
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none, // TextField 테두리 제거
                  ),
                  textAlign: TextAlign.end, // 커서 및 텍스트 오른쪽 정렬
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

  // 토글 스위치가 포함된 설정 필드 위젯을 생성합니다.
  Widget _buildToggleField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    double topRadius = 20.0,
    double bottomRadius = 20.0,
  }) {
    // 유리 효과가 적용된 컨테이너 안에 토글 스위치를 배치합니다.
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: Radius.circular(bottomRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xB2A0AFB7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: Radius.circular(bottomRadius)),
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