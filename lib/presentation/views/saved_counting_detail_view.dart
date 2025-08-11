import 'package:counting_app/data/model/category_list.dart';
import 'package:counting_app/data/repositories/counting_repository.dart';
import 'package:flutter/material.dart';

// 저장된 카운팅 목록의 상세 화면을 표시하는 위젯입니다.
class SavedCountingDetailView extends StatefulWidget {
  final CategoryList categoryList;

  const SavedCountingDetailView({super.key, required this.categoryList});

  @override
  State<SavedCountingDetailView> createState() => _SavedCountingDetailViewState();
}

class _SavedCountingDetailViewState extends State<SavedCountingDetailView> {
  late CategoryList _currentCategoryList;
  final CountingRepository _repository = CountingRepository();

  @override
  void initState() {
    super.initState();
    // 위젯의 초기 상태로 전달받은 카테고리 리스트를 설정합니다.
    _currentCategoryList = widget.categoryList;
  }

  // 카테고리 값을 변경하고 저장소에 업데이트하는 함수입니다.
  void _updateCategoryValue(int index, int change) {
    setState(() {
      final category = _currentCategoryList.categoryList[index];
      final newValue = category.value + change;

      // 음수 허용 여부를 확인합니다.
      if (!_currentCategoryList.useNegativeNum && newValue < 0) {
        return; // 음수를 허용하지 않으면 0 미만으로 내려가지 않습니다.
      }

      category.value = newValue;
      _currentCategoryList.modifyDate = DateTime.now();
    });
    // 변경된 리스트를 저장소에 즉시 저장합니다.
    _repository.updateCategoryList(_currentCategoryList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCategoryList.name),
      ),
      body: ListView.builder(
        itemCount: _currentCategoryList.categoryList.length,
        itemBuilder: (context, index) {
          final category = _currentCategoryList.categoryList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 카테고리 이름
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      // 감소 버튼
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateCategoryValue(index, -1),
                      ),
                      // 현재 값
                      Text(
                        '${category.value}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // 증가 버튼
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _updateCategoryValue(index, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
