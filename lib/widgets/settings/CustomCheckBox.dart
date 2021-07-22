import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            width: 0.4.wp,
            child: AutoSizeText(
              text,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: isActive && value
                    ? Theme.of(context).accentColor
                    : Colors.grey,
                fontSize: 32.nsp,
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Checkbox(
            activeColor: Theme.of(context).accentColor,
            value: value,
            onChanged: isActive ? changeValue : null,
          ),
        ),
      ],
    );
  }
}
