import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool) changeValue;
  final String text;

  CustomCheckBox({
    this.value,
    this.changeValue,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF9B152);
    return Row(
      children: [
        Text(text),
        Checkbox(
          activeColor: yellow,
          value: value,
          onChanged: changeValue,
        ),
      ],
    );
  }
}
