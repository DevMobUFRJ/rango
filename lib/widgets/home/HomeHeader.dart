import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  HomeHeader(this.userName);

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Stack(
      children: [
        SvgPicture.asset(
          assetName,
          semanticsLabel: 'curvaHome',
          width: 1.wp,
        ),
        Container(
          margin: EdgeInsets.only(
              top: 0.04.hp, bottom: 0.01.hp, left: 0.04.wp, right: 0.04.wp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                "Olá, $userName!",
                maxLines: 2,
                minFontSize: 30,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserratTextTheme(
                  Theme.of(context).textTheme,
                ).headline1,
              ),
              AutoSizeText(
                "Bateu a fome?",
                maxLines: 1,
                minFontSize: 30,
                style: GoogleFonts.montserratTextTheme(
                  Theme.of(context).textTheme,
                ).headline1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
