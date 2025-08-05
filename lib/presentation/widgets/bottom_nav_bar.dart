import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class BottomNavBar extends StatelessWidget {
  // 하단 네비게이션 바 위젯입니다.
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 테마의 밝기 모드를 확인합니다.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Glassmorphic 위젯을 사용하여 liquid glass 효과를 적용합니다.
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 20,
      blur: 10,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDarkMode
              ? Colors.white.withAlpha(25)
              : Colors.white.withAlpha(51),
          isDarkMode
              ? Colors.white.withAlpha(12)
              : Colors.white.withAlpha(25),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDarkMode
              ? Colors.white.withAlpha(128)
              : Colors.white.withAlpha(128),
          isDarkMode
              ? Colors.white.withAlpha(128)
              : Colors.white.withAlpha(128),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 햄버거 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          // 페이지를 나타내는 점
          const Row(
            children: [
              Icon(Icons.circle, size: 8),
              SizedBox(width: 8),
              Icon(Icons.circle, size: 8, color: Colors.grey),
              SizedBox(width: 8),
              Icon(Icons.circle, size: 8, color: Colors.grey),
            ],
          ),
          // 설정 아이콘 버튼
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
