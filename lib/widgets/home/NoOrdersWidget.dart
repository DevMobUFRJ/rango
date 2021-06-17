import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';

class NoOrdersWidget extends StatelessWidget {
  const NoOrdersWidget({
    Key key,
    @required this.assetName,
    @required this.widget,
  }) : super(key: key);

  final String assetName;
  final HomeScreen widget;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          SvgPicture.asset(
            assetName,
            semanticsLabel: 'curvaHome',
            width: 1.wp,
          ),
          Container(
            margin: EdgeInsets.only(top: 0.03.hp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 0.01.hp),
                Container(
                  width: 0.7.wp,
                  padding: EdgeInsets.symmetric(
                      horizontal: 0.04.wp, vertical: 0.01.hp),
                  child: AutoSizeText(
                    'Olá,\n${widget.usuario.name}!',
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.montserrat(
                      color: Colors.deepOrange[300],
                      fontWeight: FontWeight.w500,
                      fontSize: 60.nsp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 0.2.hp,
              horizontal: 0.05.wp,
            ),
            child: AutoSizeText(
              'Você ainda não recebeu pedidos hoje! Aproveite para gerenciar suas quentinhas e o cardápio de hoje na aba de quentinhas ou configurar horário de funcionamento, localização e outras coisas na aba de perfil!',
              style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w400,
                fontSize: 36.nsp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
