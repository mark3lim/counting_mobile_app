// 카테고리 데이터를 관리하기 위한 모델 클래스입니다.
class Category {
  String name;
  int value;
  int incrementStep;

  // 카테고리 객체를 생성합니다.
  Category({
    required this.name,
    this.value = 0,
    this.incrementStep = 1,
  });

  // 카운트를 증가시킵니다.
  void increment() {
    value += incrementStep;
  }

  // 카운트를 감소시킵니다.
  void decrement() {
    value -= incrementStep;
  }
}
