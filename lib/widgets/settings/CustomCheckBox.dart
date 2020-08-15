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
    ScreenUtil.init(context, width: 750, height: 1334);
    const orange = Color(0xFFFC744F);
    const yellow = Color(0xFFF9B152);
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
                  color: isActive ? orange : Colors.grey, fontSize: 22.nsp),
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
