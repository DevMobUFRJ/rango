import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/widgets/home/GridVertical.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  final Client usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
List<Meal> meals = [];

class _HomeScreenState extends State<HomeScreen> {
  final geo = Geoflutterfire();
  final _database = Firestore.instance;
  void _fetch() async {
    var userLocation = await Geolocator.getCurrentPosition();
    print("User location: $userLocation");

    GeoFirePoint center = geo.point(latitude: userLocation.latitude, longitude: userLocation.longitude); // Niterói
    double radius = 30; // Em km

    try {
      print("Start fetch");
      Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: _database.collection("sellers"))
          .within(center: center, radius: radius, field: "location", strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) {
        List<Meal> tempMeals = [];
        print("${documentList.length} sellers found");

        for(var i=0; i < documentList.length; i++){
          // Iterar todos os vendedores
          var seller = documentList[i];
          print("Distance to seller ${seller.data["name"]}: ${center.distance(lat: seller.data["location"]["geopoint"].latitude, lng: seller.data["location"]["geopoint"].longitude)} km");

          // TODO Limitar quantidade de pratos para seção Sugestões ou filtrar por featured?
          seller.reference.collection("meals")
              .getDocuments()
              .then((QuerySnapshot snapshot) {
            snapshot.documents.forEach((meal) {
              // Iterar todos os meals
              // print(meal.reference.parent().parent().documentID);
              Meal currentMeal = Meal.fromJson(meal.data);
              currentMeal.sellerName = seller.data["name"];
              currentMeal.sellerId = seller.documentID;
              tempMeals.add(currentMeal);
            });
          });
        }
        tempMeals.shuffle();
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