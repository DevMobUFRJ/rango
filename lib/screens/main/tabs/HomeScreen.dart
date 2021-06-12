import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/GridVertical.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/widgets/home/SellerGridVertical.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

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
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
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
                    FutureBuilder(
                      future: Repository.instance.getUserLocation(),
                      builder: (context, AsyncSnapshot<Position> locationSnapshot) {
                        if (!locationSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (locationSnapshot.hasError) {
                          return Text(locationSnapshot.error.toString());
                        }
                        return StreamBuilder(
                          stream: Repository.instance.getNearbySellersStream(locationSnapshot.data),
                          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }

                            var sellerMap = Map();
                            List<Seller> sellerList = [];
                            snapshot.data.forEach((seller) {
                              sellerMap[seller.documentID] = seller.data["name"];
                              Seller currentSeller = Seller.fromJson(seller.data, id: seller.documentID);
                              sellerList.add(currentSeller);
                              //print("${seller.data["name"]} is from cache: ${seller.metadata.isFromCache}");
                            });
                            return Column(
                              children: [
                                StreamBuilder(
                                  stream: Repository.instance.getCurrentMealsStream(snapshot.data),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Text(snapshot.error.toString());
                                    }
                                    List<Meal> tempMeals = [];
                                    snapshot.data.forEach((QuerySnapshot seller) {
                                      // Iterar todos os meals
                                      seller.documents.forEach((meal) {
                                        //print("${meal.data["name"]} is from cache: ${meal.metadata.isFromCache}");
                                        Meal currentMeal = Meal.fromJson(meal.data);
                                        currentMeal.id = meal.reference.documentID;
                                        currentMeal.sellerName = sellerMap[meal.reference.parent().parent().documentID];
                                        currentMeal.sellerId = meal.reference.parent().parent().documentID;
                                        tempMeals.add(currentMeal);
                                      });
                                      tempMeals.shuffle();
                                    });
                                    return Column(
                                      children: [
                                        FutureBuilder(
                                            future: auth.currentUser(),
                                            builder: (context, AsyncSnapshot<FirebaseUser> authSnapshot) {
                                              if (!authSnapshot.hasData) {
                                                return CircularProgressIndicator();
                                              }
                                              if (authSnapshot.hasError) {
                                                return Text(authSnapshot.error.toString());
                                              }

                                              return StreamBuilder(
                                                  stream: Repository.instance.getOrdersFromClient(authSnapshot.data.uid, limit: 10),
                                                  builder: (context, AsyncSnapshot<QuerySnapshot> orderSnapshot) {
                                                    if (!orderSnapshot.hasData) {
                                                      return CircularProgressIndicator();
                                                    }
                                                    if (orderSnapshot.hasError) {
                                                      return Text(orderSnapshot.error.toString());
                                                    }

                                                    List<Meal> orderedMeals = List.of(tempMeals);
                                                    var mealIds = orderSnapshot.data.documents.map((order) => order.data["mealId"]).toSet().toList();
                                                    orderedMeals.removeWhere((meal) => !mealIds.contains(meal.id));

                                                    if (orderedMeals.length > 0) {
                                                      return Column(
                                                        children: [
                                                          ListaHorizontal(
                                                            title: 'Peça Novamente',
                                                            tagM: Random().nextDouble(),
                                                            meals: orderedMeals,
                                                          ),
                                                          SizedBox(height: 0.02.hp),
                                                        ],
                                                      );
                                                    }

                                                    return SizedBox();
                                                  }
                                              );
                                            }
                                        ),
                                        ListaHorizontal(
                                          title: 'Sugestões',
                                          tagM: Random().nextDouble(),
                                          meals: tempMeals,
                                        )
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 0.02.hp),
                                SellerGridVertical(
                                  tagM: Random().nextDouble(),
                                  title: 'Vendedores',
                                  sellers: sellerList,
                                  userLocation: locationSnapshot.data,
                                ),
                              ],
                            );
                          }
                        );
                      },
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
