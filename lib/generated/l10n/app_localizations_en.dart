// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Counting App';

  @override
  String get dailyCounting => 'Daily Counting';

  @override
  String get basicCounting => 'Basic Counting';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get categoryExists => 'This category already exists.';

  @override
  String get nextBtn => 'Next';

  @override
  String get prevBtn => 'Previous';

  @override
  String get detailSetting => 'Detail Setting';

  @override
  String get nameTitle => 'Enter Name';

  @override
  String get useNegativeNum => 'Use Negative Number';

  @override
  String get hideToggle => 'Hide';

  @override
  String get saveBtn => 'Save';

  @override
  String get checkDeleteTitle => 'Confirm Delete';

  @override
  String get checkDeleteMessage => 'will be deleted permanently.';
}
