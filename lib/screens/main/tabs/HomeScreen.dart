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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final Client usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
List<Meal> meals = [];

class _HomeScreenState extends State<HomeScreen> {
  final _database = Firestore.instance;
  void _fetch() async {
    try {
      print("Start fetch");
      await _database.collection("sellers")
          .getDocuments()
          .then((QuerySnapshot snapshot) {
            List<Meal> tempMeals = [];
            print(snapshot.documents.length.toString() + " sellers found");
            for(var i=0; i<snapshot.documents.length; i++){
              // Iterar todos os vendedores
              var seller = snapshot.documents[i];
              seller.reference.collection("meals")
              .getDocuments()
              .then((QuerySnapshot snapshot) {
                snapshot.documents.forEach((meal) {
                  // Iterar todos os meals
                  Meal currentMeal = Meal.fromJson(meal.data);
                  currentMeal.sellerName = seller.data["name"];
                  currentMeal.sellerId = seller.documentID;
                  tempMeals.add(currentMeal);
                });
              });
            }
            meals = tempMeals;
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    _fetch();
    print(meals);
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 0.01.hp),
                    Container(
                      width: 0.7.wp,
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.04.wp, vertical: 0.01.hp),
                      child: AutoSizeText(
                        'Olá, ${widget.usuario.name.split(" ")[0]}!\nBateu a fome?',
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.montserratTextTheme(
                                Theme.of(context).textTheme)
                            .headline1,
                      ),
                    ),
                    SizedBox(height: 0.06.hp),
                    ListaHorizontal(
                      title: 'Peça novamente',
                      tagM: Random().nextDouble(),
                      meals: meals,
                    ),
                    SizedBox(height: 0.02.hp),
                    ListaHorizontal(
                      title: 'Sugestões',
                      tagM: Random().nextDouble(),
                      meals: meals,
                    ),
                    SizedBox(height: 0.02.hp),
                    GridVertical(
                      tagM: Random().nextDouble(),
                      title: 'Recomendado para você',
                      meals: meals,
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