import 'package:flutter/material.dart';

class CountingCard extends StatefulWidget {
  // 카드에 표시될 텍스트입니다.
  final String text;

  // 카드를 눌렀을 때 실행될 콜백 함수입니다.
  final VoidCallback? onTap;

  const CountingCard({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  State<CountingCard> createState() => _CountingCardState();
}

class _CountingCardState extends State<CountingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    // 터치 이벤트를 감지하는 위젯입니다.
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Card(
            elevation: 2.0,
            color: Color.lerp(cardColor, highlightColor, _controller.value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
