import 'package:flutter/material.dart';

import '../../theme.dart';

class CityTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const CityTextField({
    Key? key,
    required this.controller,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        enabledBorder: OutlineInputBorder(),
        hintText: label,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CityTheme.cityblue),
        ),
        border: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(),
      ),
    );
  }
}
