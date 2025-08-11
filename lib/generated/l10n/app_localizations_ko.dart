// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '카운팅 앱';

  @override
  String get dailyCounting => '일일 카운팅';

  @override
  String get basicCounting => '기본 카운팅';

  @override
  String get addDailyCounting => '일일 카운팅 추가';

  @override
  String get addBasicCounting => '기본 카운팅 추가';

  @override
  String get addCategory => '카테고리 추가';

  @override
  String get categoryName => '카테고리 이름';

  @override
  String get add => '추가';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get categoryExists => '이미 존재하는 카테고리입니다.';

  @override
  String get nextBtn => '다음';

  @override
  String get prevBtn => '이전';

  @override
  String get detailSetting => '상세 설정';

  @override
  String get nameTitle => '이름 설정';

  @override
  String get useNegativeNum => '음수 사용';

  @override
  String get hideToggle => '숨기기';

  @override
  String get saveBtn => '저장';

  @override
  String get checkDeleteTitle => '삭제 확인';

  @override
  String get checkDeleteMessage => '항목을 정말 삭제하시겠습니까?';

  @override
  String get nameRequired => '이름을 입력해주세요.';

  @override
  String get saveFailedMessage => '저장에 실패했습니다. 다시 시도해주세요.';

  @override
  String get deleteFailedMessage => '삭제에 실패했습니다. 다시 시도해주세요.';
}
