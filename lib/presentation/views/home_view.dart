import 'package:counting_app/data/model/category_list.dart';
import 'package:counting_app/data/repositories/counting_repository.dart';
import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:counting_app/presentation/views/basic_counting_view.dart';
import 'package:counting_app/presentation/views/daily_counting_view.dart';
import 'package:counting_app/presentation/views/saved_counting_detail_view.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/counting_card.dart';

// 홈 화면을 표시하는 상태를 가진 위젯입니다.
class HomeView extends StatefulWidget {
  // 홈 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/home';

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final CountingRepository _repository;
  List<CategoryList> _categoryLists = [];

  @override
  void initState() {
    // 위젯이 초기화될 때 저장된 카테고리 목록을 불러옵니다.
    super.initState();
    _loadCategoryLists();
  }

  // 저장소에서 카테고리 목록을 비동기적으로 불러와 상태를 업데이트합니다.
  Future<void> _loadCategoryLists() async {
    try {
      final fetched = await _repository.getAllCategoryLists();
      // 최근 수정된 순서로 정렬 (원본 변조 방지를 위해 복사본 사용)
      final lists = List<CategoryList>.of(fetched)
        ..sort((a, b) => b.modifyDate.compareTo(a.modifyDate));
      if (!mounted) return;
      setState(() {
        _categoryLists = lists;
      });
    } catch (e) {
      if (!mounted) return;
      // 에러 처리: 스낵바나 다이얼로그로 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 상세 화면으로 이동하고, 돌아왔을 때 목록을 새로고침하는 함수입니다.
  void _navigateToDetail(CategoryList categoryList) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedCountingDetailView(categoryList: categoryList),
      ),
    );
    // 상세 화면에서 돌아오면 목록을 다시 불러와 최신 상태를 반영합니다.
    _loadCategoryLists();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // 화면의 기본 구조를 설정합니다.
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        titleTextStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.0),
      ),
      body: _categoryLists.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  CountingCard(
                    text: localizations.addDailyCounting,
                    textAlign: TextAlign.left,
                    onTap: () =>
                        Navigator.pushNamed(context, DailyCountingView.routeName),
                    icon: Icons.calendar_month,
                  ),
                  const SizedBox(height: 8),
                  CountingCard(
                    text: localizations.addBasicCounting,
                    textAlign: TextAlign.left,
                    onTap: () =>
                        Navigator.pushNamed(context, BasicCountingView.routeName),
                    icon: Icons.list_alt,
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // 저장된 카테고리 목록을 동적으로 표시합니다.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final categoryList = _categoryLists[index];
                        return Dismissible(
                          key: Key(categoryList.id),
                          direction: DismissDirection.endToStart,
                          // 삭제 확인 다이얼로그를 표시합니다.
                          confirmDismiss: (direction) async {
                            final bool? confirmed = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(localizations.checkDeleteTitle),
                                  content: Text(
                                      "'${categoryList.name} ${localizations.checkDeleteMessage}'"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(localizations.cancel),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text(localizations.delete),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                );
                              },
                            );
                            return confirmed;
                          },
                          // 다이얼로그에서 '삭제'를 선택한 경우에만 호출됩니다.
                          onDismissed: (direction) async {
                            final index = _categoryLists.indexOf(categoryList);
                            final item = _categoryLists[index];

                            setState(() {
                              _categoryLists.removeAt(index);
                            });

                            try {
                              await _repository.deleteCategoryList(item.id);
                            } catch (e) {
                              setState(() {
                                _categoryLists.insert(index, item);
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(localizations.deleteFailedMessage),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                            child: CountingCard(
                              text: categoryList.name,
                              textAlign: TextAlign.left,
                              onTap: () => _navigateToDetail(categoryList),
                              icon: 'basic' == categoryList.categoryType
                                  ? Icons.list_alt
                                  : Icons.calendar_month,
                            ),
                          ),
                        );
                      },
                      childCount: _categoryLists.length,
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
