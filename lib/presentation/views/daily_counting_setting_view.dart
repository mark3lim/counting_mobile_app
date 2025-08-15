import 'dart:ui';

import 'package:counting_app/data/model/category.dart';
import 'package:counting_app/data/model/category_list.dart';
import 'package:counting_app/data/repositories/counting_repository.dart';
import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/widgets/custom_app_save_bar.dart';
import 'package:counting_app/presentation/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DailyCountingSettingView extends StatefulWidget {
  static const String routeName = '/daily_counting_setting';

  final List<Category> categories;

  const DailyCountingSettingView({super.key, required this.categories});

  @override
  State<DailyCountingSettingView> createState() => _DailyCountingSettingViewState();
}

class _DailyCountingSettingViewState extends State<DailyCountingSettingView> {
  late TextEditingController _nameController;
  late final CountingRepository _repository;
  bool _isHidden = false;
  bool _isSaving = false;
  bool _isNameEmpty = true;
  late String _selectedCycle;
  late List<String> _cycleOptions;
  bool _didChangeDependencies = false;
  bool _allowNegative = false;
  bool _isForAnalyze = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _isNameEmpty = _nameController.text.trim().isEmpty;
    _nameController.addListener(() {
      final isEmpty = _nameController.text.trim().isEmpty;
      if (_isNameEmpty != isEmpty && mounted) {
        setState(() {
          _isNameEmpty = isEmpty;
        });
      }
    });
    _repository = CountingRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didChangeDependencies) {
      _selectedCycle = AppLocalizations.of(context)!.daily;
      _cycleOptions = [
        AppLocalizations.of(context)!.daily,
        AppLocalizations.of(context)!.weekly,
        AppLocalizations.of(context)!.monthly,
      ];
      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

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
        categoryType: 'daily',
        cycleType: _selectedCycle,
        isForAnalyze: _isForAnalyze,
      );

      await _repository.addCategoryList(newCategoryList);

      if (mounted) {
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

  void _showCyclePicker() {
    final selectedIndex = _cycleOptions.indexOf(_selectedCycle);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(initialItem: selectedIndex),
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedCycle = _cycleOptions[index];
              });
            },
            children: _cycleOptions.map((String value) {
              return Center(child: Text(value));
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppSaveBar(
        title: AppLocalizations.of(context)!.detailSetting,
        onSavePressed: _onSave,
        saveButtonTextColor: _isNameEmpty ? Colors.grey.shade400 : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNameTextField(
              controller: _nameController,
              label: AppLocalizations.of(context)!.nameInputTitle,
              hintText: AppLocalizations.of(context)!.nameInputHint,
              bottomRadius: 0.0,
            ),
            _buildCycleField(
              topRadius: 0.0,
            ),
            const SizedBox(height: 16.0),
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
            const SizedBox(height: 16.0),
            _buildToggleField(
              label: AppLocalizations.of(context)!.useAnalyzTitle,
              value: _isForAnalyze,
              onChanged: (value) {
                setState(() {
                  _isForAnalyze = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTextField({
    required TextEditingController controller,
    required String label,
    String hintText = '',
    double topRadius = 20.0,
    double bottomRadius = 20.0,
  }) {
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
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.end,
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

  Widget _buildCycleField({
    double topRadius = 20.0,
    double bottomRadius = 20.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: Radius.circular(bottomRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: _showCyclePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xB2A0AFB7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ZZZZ",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
                ),
                Text(
                  _selectedCycle,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    double topRadius = 20.0,
    double bottomRadius = 20.0,
  }) {
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