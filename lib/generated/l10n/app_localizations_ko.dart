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
}
