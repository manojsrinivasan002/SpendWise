import 'package:flutter/material.dart';

class StickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  StickyDateHeaderDelegate({required this.title});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        height: maxExtent,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 45.0;

  @override
  double get minExtent => 45.0;

  @override
  bool shouldRebuild(covariant StickyDateHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
