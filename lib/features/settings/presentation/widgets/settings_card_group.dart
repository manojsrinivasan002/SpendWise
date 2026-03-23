import 'package:flutter/material.dart';

class SettingsCardGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsCardGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Container(child: Column(children: children)),
      ],
    );
  }
}
