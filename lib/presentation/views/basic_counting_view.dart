import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 카테고리 데이터를 관리하기 위한 모델 클래스입니다.
class _Category {
  String name;
  int value;

  // 카테고리 객체를 생성합니다.
  _Category({required this.name, this.value = 0});
}

class BasicCountingView extends StatefulWidget {
  // 기본 카운팅 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/basic_counting';

  const BasicCountingView({super.key});

  @override
  State<BasicCountingView> createState() => _BasicCountingViewState();
}

class _BasicCountingViewState extends State<BasicCountingView> {
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
    if (name.isNotEmpty && !_categories.any((category) => category.name == name)) {
      setState(() {
        _categories.insert(0, _Category(name: name, value: 0)); // 목록의 맨 위에 추가
        _isAddingCategory = false;
        _nameController.clear();
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.basicCounting),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80), // FAB 공간 확보
        children: _buildListViewItems(),
      ),
    );
  }

  // ListView에 표시될 위젯 목록을 동적으로 생성합니다.
  List<Widget> _buildListViewItems() {
    final List<Widget> items = [];

    // 1. 카테고리 추가 입력 카드를 조건부로 추가합니다.
    if (_isAddingCategory) {
      items.add(_buildInputCard());
    }

    // 2. "카테고리 추가" 버튼을 추가합니다.
    items.add(_buildAddCategoryButton());

    // 3. 기존 카테고리 목록을 추가합니다.
    for (int i = 0; i < _categories.length; i++) {
      items.add(_buildCategoryItem(_categories[i], i));
    }

    return items;
  }

  // 카테고리 입력을 위한 카드 위젯을 생성합니다.
  Widget _buildInputCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            // 카테고리명 입력 필드
            Expanded(
              child: TextField(
                controller: _nameController,
                maxLength: 25,
                autofocus: true,
                inputFormatters: [LengthLimitingTextInputFormatter(25)],
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.categoryName,
                  counterText: '', // 글자 수 카운터 숨기기
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 추가 버튼
            InkWell(
              onTap: _addNewCategory,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "카테고리 추가" 버튼 위젯을 생성합니다.
  Widget _buildAddCategoryButton() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListTile(
        title: Text(AppLocalizations.of(context)!.addCategory),
        trailing: const Icon(Icons.add, color: Color(0xFF4CAF50)),
        onTap: _toggleAddCategoryView,
        // 입력 창이 열려있을 때는 버튼을 비활성화한 것처럼 보이게 처리
        enabled: !_isAddingCategory,
      ),
    );
  }

  // 각 카테고리 항목을 위한 위젯을 생성합니다.
  Widget _buildCategoryItem(_Category category, int index) {
    return Dismissible(
      key: Key('${category.name}_${index}_${category.hashCode}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _categories.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${category.name} ${AppLocalizations.of(context)!.delete}'),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          title: Text(category.name),
          trailing: Text(
            category.value.toString(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}