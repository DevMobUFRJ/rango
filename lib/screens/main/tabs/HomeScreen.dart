import 'dart:async';
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
import 'package:rxdart/rxdart.dart' show CombineLatestStream;

class HomeScreen extends StatefulWidget {
  final Client usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final geo = Geoflutterfire();
  final _database = Firestore.instance;

  Stream<Position> getUserLocationStream() {
    // Stream para pegar a localização da pessoa
    return Geolocator.getCurrentPosition().asStream();
  }

  Stream<List<DocumentSnapshot>> getSellersStream(Position userLocation) {
    // Stream para pegar os vendedores próximos
    GeoFirePoint center = geo.point(latitude: userLocation.latitude, longitude: userLocation.longitude);
    double radius = 30; // Em km TODO Pegar isso de SharedPreferences
    var queryRef = _database.collection("sellers"); //.where("active", isEqualTo: true); //TODO Adicionar query por "active" e "shift"
    return geo.collection(collectionRef: queryRef)
        .within(center: center, radius: radius, field: "location", strictMode: true);
  }

  Stream<List<QuerySnapshot>> getMealsStream(List<DocumentSnapshot> documentList) {
    List<Stream<QuerySnapshot>> streams = [];

    for (var i = 0; i < documentList.length; i++) {
      // Iterar todos os vendedores
      var seller = documentList[i];

      // TODO Limitar quantidade de pratos para seção Sugestões e filtrar por featured
      streams.add(seller.reference.collection("meals").getDocuments().asStream()); //.where("featured", isEqualTo: true).limit(2)
    }

    return CombineLatestStream.list<QuerySnapshot>(streams).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
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
                    StreamBuilder(
                      stream: getUserLocationStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        return StreamBuilder(
                          stream: getSellersStream(snapshot.data),
                          builder: (context, AsyncSnapshot<List<DocumentSnapshot> >snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            var sellerMap = Map();
                            snapshot.data.forEach((seller) {
                              sellerMap[seller.documentID] = seller.data["name"];
                            });
                            return StreamBuilder(
                              stream: getMealsStream(snapshot.data),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                List<Meal> tempMeals = [];
                                snapshot.data.forEach((QuerySnapshot seller) {
                                  // Iterar todos os meals
                                  seller.documents.forEach((meal) {
                                    Meal currentMeal = Meal.fromJson(meal.data);
                                    currentMeal.id = meal.reference.documentID;
                                    currentMeal.sellerName = sellerMap[meal.reference.parent().parent().documentID];
                                    currentMeal.sellerId = meal.reference.parent().parent().documentID;
                                    tempMeals.add(currentMeal);
                                  });
                                });
                                return ListaHorizontal(
                                  title: 'Peça novamente',
                                  tagM: Random().nextDouble(),
                                  meals: tempMeals,
                                );
                              },
                            );
                          }
                        );
                      },
                    ),
                    SizedBox(height: 0.02.hp),
                    ListaHorizontal(
                      title: 'Sugestões',
                      tagM: Random().nextDouble(),
                      meals: [],
                    ),
                    SizedBox(height: 0.02.hp),
                    GridVertical(
                      tagM: Random().nextDouble(),
                      title: 'Recomendado para você',
                      meals: [],
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
