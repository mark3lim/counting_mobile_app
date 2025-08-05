import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/widgets/liquid_glass_button.dart';
import 'package:counting_app/presentation/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 카테고리 데이터를 관리하기 위한 모델 클래스입니다.
class _Category {
  String name;
  int value;


  // 카테고리 객체를 생성합니다.
  _Category({required this.name, this.value = 0});

  // 카운트를 1 증가시킵니다.
  void increment() => value++;

  // 카운트를 1 감소시킵니다.
  void decrement() {
    if (value > 0) {
      value--;
    }
  }
}

class BasicCountingView extends StatefulWidget {
  // 기본 카운팅 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/basic_counting';

  const BasicCountingView({super.key});

  @override
  State<BasicCountingView> createState() => _BasicCountingViewState();
}

class _BasicCountingViewState extends State<BasicCountingView> {
  // 카드 여백과 높이를 상수로 정의하여 중복을 줄입니다.
  static const _inputCardMargin = EdgeInsets.fromLTRB(16, 16, 16, 8);
  static const _addCategoryCardMargin = EdgeInsets.fromLTRB(16, 8, 16, 8);
  static const _categoryItemCardMargin = EdgeInsets.symmetric(horizontal: 14, vertical: 4);
  static const double _kItemHeight = 72.0;
  static const _cardBoarderRadius = 30.0;
  static const _edgeInsetsHorizontal = 20.0;

  // 카테고리 목록과 입력 상태를 관리합니다.
  final List<_Category> _categories = [];
  final TextEditingController _nameController = TextEditingController();
  bool _isAddingCategory = false;

  // 카테고리 추가 입력 UI의 표시 상태를 토글합니다.
  void _toggleAddCategoryView() {
    setState(() {
      _isAddingCategory = !_isAddingCategory;
      if (!_isAddingCategory) {
        _nameController.clear();
      }
    });
  }

  // 새 카테고리를 목록에 추가합니다.
  void _addNewCategory() {
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
        _categories.add(_Category(name: name));
        _isAddingCategory = false;
        _nameController.clear();
      });
    }
  }

  // 카테고리 값을 증가시킵니다.
  void _incrementCategoryValue(_Category category) {
    setState(() {
      category.increment();
    });
  }

  // 카테고리 값을 감소시킵니다.
  void _decrementCategoryValue(_Category category) {
    setState(() {
      category.decrement();
    });
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.basicCounting),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 21.0,
          color: Theme.of(context).colorScheme.onSurface,
        ),
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
                final _Category item = _categories.removeAt(oldIndex);
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
      floatingActionButton: SettingsButton(
        onPressed: () {
          // TODO: 설정 화면으로 이동하는 로직 구현
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings button pressed!')),
          );
        },
      ),
    );
  }

  // 카테고리 입력을 위한 카드 위젯을 생성합니다.
  Widget _buildInputCard() {
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: _edgeInsetsHorizontal
                    ),
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
    return SizedBox(
      height: _kItemHeight,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBoarderRadius),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.0),
        ),
        margin: _addCategoryCardMargin,
        child: ListTile(
          title: Text(AppLocalizations.of(context)!.addCategory),
          trailing: const Icon(Icons.add, color: Color(0xFF4CAF50)),
          onTap: _toggleAddCategoryView,
          // 입력 창이 열려있을 때는 버튼을 비활성화한 것처럼 보이게 처리
          enabled: !_isAddingCategory,
        ),
      ),
    );
  }

  // 각 카테고리 항목을 위한 위젯을 생성합니다.
  Widget _buildCategoryItem(_Category category, int index) {
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
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding:
              const EdgeInsets.symmetric(horizontal: _edgeInsetsHorizontal),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Padding(
          padding: _categoryItemCardMargin,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          category.value.toString(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 10), // 숫자 왼쪽에 간격 추가
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 빼기 버튼
              LiquidGlassButton(
                onPressed: () => _decrementCategoryValue(category),
                icon: Icons.remove,
                color: const Color(0xFFF44336),
              ),
              const SizedBox(width: 8),
              // 더하기 버튼
              LiquidGlassButton(
                onPressed: () => _incrementCategoryValue(category),
                icon: Icons.add,
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}