import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  const AnimatedCard({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOutQuint,
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = (index * 0.2);
        final adjustedValue = (value - delay).clamp(0.0, 1.0) / (1.0 - delay);
        return Transform.translate(
          offset: Offset(0, 50 * (1 - adjustedValue)),
          child: Opacity(opacity: adjustedValue, child: child),
        );
      },
      child: child,
    );
  }
}
