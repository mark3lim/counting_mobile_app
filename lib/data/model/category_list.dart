import 'package:collection/collection.dart';
import 'package:counting_app/data/model/category.dart';
import 'package:uuid/uuid.dart';

class CategoryList {
  final String id; //고유 ID
  String name; //이름
  List<Category> categoryList; //카테고리
  List<String> categoryNameList; // 카테고리명 리스트
  DateTime modifyDate; // 생성, 수정 일자
  bool useNegativeNum; // 음수 사용 여부
  bool isHidden; // 숨김 여부

  CategoryList({
    required this.name,
    required this.categoryList,
    required this.categoryNameList,
    required this.modifyDate,
    this.useNegativeNum = false, // 음수 사용 여부
    this.isHidden = false, // 숨김 여부
  }) : id = Uuid().v4();

  bool isCategoryNameSame(List<String> nameList) {
    return ListEquality().equals(categoryNameList, nameList);
  }
}