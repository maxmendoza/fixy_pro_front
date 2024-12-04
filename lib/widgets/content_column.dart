import 'package:flutter/material.dart';

class ContentColumn extends StatelessWidget {
  final String title;
  final String text;
  const ContentColumn({super.key, required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(title),
          Text(text),
        ],
      ),
    );
  }
}
