import 'package:flutter/material.dart';

import '../../theme.dart';

class CityTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;

  final void Function(String)? onChanged;

  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  const CityTextField({
    Key? key,
    this.controller,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        hintText: label,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CityTheme.cityblue),
          borderRadius: BorderRadius.circular(6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
