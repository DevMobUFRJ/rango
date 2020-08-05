import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/widgets/home/GridVertical.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';

class HomeScreen extends StatefulWidget {
  final _username;

  HomeScreen(this._username);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    List<Meal> meals = new List<Meal>();
    sellers.forEach((element) {
      meals.add(element.currentMeals[0]);
    });
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              child: SvgPicture.asset(
                assetName,
                semanticsLabel: 'curvaHome',
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: Text(
                      'Olá, ${widget._username}!\nBateu a fome?',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserratTextTheme(
                              Theme.of(context).textTheme)
                          .headline1,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.21,
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: ListaHorizontal(
                      title: 'Peça novamente',
                      meals: meals,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: GridVertical(
                      title: 'Promoções da semana',
                      meals: meals,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
