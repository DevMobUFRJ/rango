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
          margin: EdgeInsets.only(top: 0.03.hp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.01.hp),
              Container(
                width: 0.7.wp,
                padding: EdgeInsets.symmetric(
                    horizontal: 0.04.wp, vertical: 0.01.hp),
                child: AutoSizeText(
                  'Olá, $userName!\nBateu a fome?',
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.montserratTextTheme(
                          Theme.of(context).textTheme)
                      .headline1,
                ),
              ),
              SizedBox(height: 0.06.hp),
            ],
          ),
        ),
      ],
    );
  }
}