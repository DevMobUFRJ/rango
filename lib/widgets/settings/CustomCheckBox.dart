import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool) changeValue;
  final String text;
  final bool isActive;

  CustomCheckBox({
    this.value,
    this.changeValue,
    this.text,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFC744F);
    const yellow = Color(0xFFF9B152);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              text,
              overflow: TextOverflow.clip,
              style: TextStyle(color: isActive ? orange : Colors.grey),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Checkbox(
            activeColor: yellow,
            value: value,
            onChanged: isActive ? changeValue : null,
          ),
        ),
      ],
    );
  }
}
