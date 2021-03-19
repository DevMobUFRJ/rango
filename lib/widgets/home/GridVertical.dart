import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';

class GridVertical extends StatelessWidget {
  final String title;

  GridVertical({
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 0.2.hp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.04.hp),
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28.nsp,
            ),
          ),
        ),
        SizedBox(height: 0.01.hp),
        Container(
          height: 0.46.hp,
          padding: EdgeInsets.symmetric(horizontal: 0.02.hp),
          width: double.infinity,
          child: Text(title),
        ),
      ],
    );
  }
}
