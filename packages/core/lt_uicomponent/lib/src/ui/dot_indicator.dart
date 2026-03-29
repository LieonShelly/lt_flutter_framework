import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;
  final Color? inActiveColor, activeColor;

  const DotIndicator({
    super.key,
    required this.isActive,
    this.inActiveColor,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor ?? Color(0xFFA390FF),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}
