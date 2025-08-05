import 'package:counting_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DailyCountingView extends StatelessWidget {
  // 데일리 카운팅 뷰의 라우트 이름을 정의합니다.
  static const String routeName = '/daily_counting';

  const DailyCountingView({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면의 기본 구조를 설정합니다.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dailyCounting),
      ),
      body: const Center(
        child: Text('Daily Counting View'),
      ),
    );
  }
}
