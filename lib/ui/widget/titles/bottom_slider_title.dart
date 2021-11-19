import 'package:flutter/material.dart';

class BottomSliderTitle extends StatelessWidget {
  final String title;

  const BottomSliderTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey[800],
      ),
    );
  }
}
