// 카테고리 데이터를 관리하기 위한 모델 클래스입니다.
class Category {
  String name;
  int value;

  // 카테고리 객체를 생성합니다.
  Category({
    required this.name,
    this.value = 0,
  });
}
