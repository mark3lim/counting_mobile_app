import 'dart:ui';

import 'package:counting_app/data/model/category.dart';
import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/views/basic_counting_setting_view.dart';
import 'package:counting_app/presentation/widgets/custom_app_bar.dart';
import 'package:counting_app/presentation/widgets/liquid_glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicCountingView extends StatefulWidget {
  // 기본 카운팅 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/basic_counting';

  const BasicCountingView({super.key});

  @override
  State<BasicCountingView> createState() => _BasicCountingViewState();
}

class _BasicCountingViewState extends State<BasicCountingView> {
  // 카드 여백과 높이를 상수로 정의하여 중복을 줄입니다.
  static const _inputCardMargin = EdgeInsets.fromLTRB(16, 12, 16, 12);
  static const _categoryItemCardMargin = EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  static const double _kItemHeight = 72.0;
  static const _cardBoarderRadius = 30.0;
  static const _edgeInsetsHorizontal = 20.0;

  // 카테고리 목록과 입력 상태를 관리합니다.
  final List<Category> _categories = [];
  final TextEditingController _nameController = TextEditingController();
  bool _isAddingCategory = false;

  // 설정 값을 관리합니다.
  int _initialValue = 0;
  int _incrementStep = 1;

  // 카테고리 추가 입력 UI의 표시 상태를 토글합니다.
  void _toggleAddCategoryView() {
    // 카테고리 추가 UI를 토글합니다.
    setState(() {
      _isAddingCategory = !_isAddingCategory;
      if (!_isAddingCategory) {
        _nameController.clear();
      }
    });
  }

  // 새 카테고리를 목록에 추가합니다.
  void _addNewCategory() {
    // 새 카테고리를 추가합니다.
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    // 동일 카테고리 알림 기능
    if (_categories.any((category) => category.name == name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.categoryExists),
        ),
      );
    } else {
      setState(() {
        // 1. 새 카테고리를 리스트의 맨 아래에 추가합니다.
        _categories.add(Category(
          name: name,
          value: _initialValue,
          incrementStep: _incrementStep,
        ));
        _isAddingCategory = false;
        _nameController.clear();
      });
    }
  }

  // 설정 화면으로 이동하고 결과를 처리합니다.
  void _navigateToSettings() async {
    // 설정 화면으로 이동합니다.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BasicCountingSettingView(categories: _categories),
      ),
    );

    if (result != null && result is Map<String, int>) {
      setState(() {
        _initialValue = result['initialValue']!;
        _incrementStep = result['incrementStep']!;
        // 모든 카테고리의 증가/감소 단위를 업데이트합니다.
        for (var category in _categories) {
          category.incrementStep = _incrementStep;
        }
      });
    }
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 컨트롤러 리소스를 해제합니다.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 기본 구조를 설정합니다.
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.basicCounting,
        isNextEnabled: _categories.isNotEmpty,
        onNextPressed: () {
          if (_categories.isNotEmpty) {
            _navigateToSettings();
          }
        },
      ),
      // 등록된 카테고리를 위 아래로 움직일 수 있게 CustomScrollView와 SliverReorderableList 사용
      body: CustomScrollView(
        slivers: [
          // 2. 위젯 표시 순서 변경: 카테고리 목록
          SliverReorderableList(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(_categories[index], index);
            },
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Material(
                type: MaterialType.transparency,
                child: child,
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Category item = _categories.removeAt(oldIndex);
                _categories.insert(newIndex, item);
              });
            },
          ),

          // 2. 위젯 표시 순서 변경: 입력 카드 (조건부)
          if (_isAddingCategory) SliverToBoxAdapter(child: _buildInputCard()),

          // 2. 위젯 표시 순서 변경: "카테고리 추가" 버튼
          SliverToBoxAdapter(child: _buildAddCategoryButton()),
        ],
      ),
    );
  }

  // 카테고리 입력을 위한 카드 위젯을 생성합니다.
  Widget _buildInputCard() {
    // 카테고리 입력 카드를 빌드합니다.
    return SizedBox(
      height: _kItemHeight,
      child: Padding(
        padding: _inputCardMargin,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_cardBoarderRadius),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.0),
                ),
                margin: EdgeInsets.zero,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _edgeInsetsHorizontal),
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.categoryName,
                        counterText: '', // 글자 수 카운터 숨기기
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addNewCategory(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 취소 버튼
            LiquidGlassButton(
              onPressed: _toggleAddCategoryView,
              icon: Icons.remove,
              color: const Color(0xFFF44336),
            ),
          ],
        ),
      ),
    );
  }

  // "카테고리 추가" 버튼 위젯을 생성합니다.
  Widget _buildAddCategoryButton() {
    // 카테고리 추가 버튼을 빌드합니다.
    final isEnabled = !_isAddingCategory;
    return SizedBox(
      height: _kItemHeight,
      child: Padding(
        padding: _inputCardMargin,
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardBoarderRadius),
            side: BorderSide(
              color: isEnabled ? Theme.of(context).colorScheme.outline : Colors.grey,
              width: 1.0,
            ),
          ),
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: isEnabled ? _toggleAddCategoryView : null,
            borderRadius: BorderRadius.circular(_cardBoarderRadius),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.addCategory,
                    style: TextStyle(
                        color: isEnabled
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.add,
                    color: isEnabled ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 각 카테고리 항목을 위한 위젯을 생성합니다.
  Widget _buildCategoryItem(Category category, int index) {
    // 카테고리 항목을 빌드합니다.
    // ReorderableList의 아이템은 최상위에 고유한 Key를 가져야 합니다.
    return SizedBox(
      key: ValueKey(category),
      height: _kItemHeight,
      child: Dismissible(
        key: ObjectKey(category),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            // index 대신 category 객체로 안전하게 제거
            _categories.remove(category);
          });
        },
        background: Container(
          // 삭제 UI를 표시하는 컨테이너입니다.
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: _edgeInsetsHorizontal),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ],
          ),
        ),
        child: Padding(
          padding: _categoryItemCardMargin,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_cardBoarderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withAlpha(77),
                        borderRadius: BorderRadius.circular(_cardBoarderRadius),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 12, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(8, 3, 8, 8),
                                child: Icon(Icons.drag_handle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
