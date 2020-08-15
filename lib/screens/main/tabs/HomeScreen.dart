import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/widgets/home/GridVertical.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';

class HomeScreen extends StatefulWidget {
  final Client usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    List<Meal> meals = new List<Meal>();
    sellers.forEach((element) {
      meals.add(element.currentMeals[0]);
    });
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height - 56,
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              SvgPicture.asset(
                assetName,
                semanticsLabel: 'curvaHome',
                width: 1.wp,
              ),
              Container(
                margin: EdgeInsets.only(top: 0.03.hp),
                width: 1.wp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 0.6.wp,
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.04.wp, vertical: 10),
                      child: AutoSizeText(
                        'Olá, ${widget.usuario.name.split(" ")[0]}!\nBateu a fome?',
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.montserratTextTheme(
                                Theme.of(context).textTheme)
                            .headline1,
                      ),
                    ),
                    SizedBox(height: 0.05.hp),
                    Container(
                      height: 260.h,
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: ListaHorizontal(
                        title: 'Peça novamente',
                        meals: meals,
                        tagM: new Random().nextDouble(),
                      ),
                    ),
                    SizedBox(height: 0.01.hp),
                    Container(
                      height: 260.h,
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: ListaHorizontal(
                        title: 'Sugestões para você',
                        meals: meals,
                        tagM: new Random().nextDouble(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: GridVertical(
                        title: 'Promoções da semana',
                        meals: meals,
                        tagM: new Random().nextDouble(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
