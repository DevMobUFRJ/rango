import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/widgets/home/SellerGridVertical.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
          height: 1.hp - 56,
          child: RefreshIndicator(
            onRefresh: () {
              setState(() {});
              return Future.value();
            },
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    _buildHeader(),
                    FutureBuilder(
                      future: Repository.instance.getUserLocation(),
                      builder: (
                        context,
                        AsyncSnapshot<Position> locationSnapshot,
                      ) {
                        if (!locationSnapshot.hasData ||
                            locationSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return Container(
                            height: 0.5.hp,
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          );
                        }

                        if (locationSnapshot.hasError) {
                          return Container(
                            height: 0.6.hp - 56,
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              locationSnapshot.error.toString(),
                              style: GoogleFonts.montserrat(
                                  fontSize: 45.nsp,
                                  color: Theme.of(context).accentColor),
                            ),
                          );
                        }

                        return Consumer<RangeChangeNotifier>(
                          builder: (context, shouldChange, child) {
                            return FutureBuilder(
                              future: Repository.instance.getSellerRange(),
                              builder: (
                                context,
                                AsyncSnapshot<double> rangeSnapshot,
                              ) {
                                if (!rangeSnapshot.hasData ||
                                    rangeSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return Container(
                                    height: 0.5.hp,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  );
                                }
                                if (rangeSnapshot.hasError) {
                                  return Container(
                                    height: 0.6.hp - 56,
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      rangeSnapshot.error.toString(),
                                      style: GoogleFonts.montserrat(
                                          fontSize: 45.nsp,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  );
                                }

                                return StreamBuilder(
                                  stream: Repository.instance
                                      .getNearbySellersStream(
                                    locationSnapshot.data,
                                    rangeSnapshot.data,
                                    queryByActive: false,
                                    queryByTime: false,
                                  ),
                                  builder: (
                                    context,
                                    AsyncSnapshot<List<DocumentSnapshot>>
                                        snapshot,
                                  ) {
                                    if (!snapshot.hasData ||
                                        snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                      return Container(
                                        height: 0.5.hp,
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Container(
                                        height: 0.6.hp - 56,
                                        alignment: Alignment.center,
                                        child: AutoSizeText(
                                          snapshot.error.toString(),
                                          style: GoogleFonts.montserrat(
                                              fontSize: 45.nsp,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      );
                                    }

                                    List<MealRequest> allMealsRequests = [];
                                    List<MealRequest> filteredMealsRequests =
                                        [];

                                    List<Seller> sellerList = [];
                                    snapshot.data.forEach((sellerDoc) {
                                      Seller seller = Seller.fromJson(
                                        sellerDoc.data,
                                        id: sellerDoc.documentID,
                                      );
                                      sellerList.add(seller);
                                      //print("${seller.data["name"]} is from cache: ${seller.metadata.isFromCache}");
                                      var filterByFeatured = false;
                                      var mealsLimit = 0;
                                      var currentMeals = seller.currentMeals;

                                      var sellerAll =
                                          currentMeals.entries.map((meal) {
                                        return MealRequest(
                                            mealId: meal.key, seller: seller);
                                      }).toList();
                                      allMealsRequests.addAll(sellerAll);

                                      if (filterByFeatured) {
                                        currentMeals.removeWhere(
                                            (mealId, details) =>
                                                !details.featured);
                                      }
                                      var sellerFiltered =
                                          currentMeals.entries.map((meal) {
                                        return MealRequest(
                                            mealId: meal.key, seller: seller);
                                      }).toList();
                                      if (mealsLimit > 0) {
                                        sellerFiltered = sellerFiltered
                                            .take(mealsLimit)
                                            .toList();
                                      }
                                      filteredMealsRequests
                                          .addAll(sellerFiltered);
                                    });

                                    if (allMealsRequests.isEmpty &&
                                        filteredMealsRequests.isEmpty &&
                                        sellerList.isEmpty)
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        height: 0.7.wp - 56,
                                        alignment: Alignment.center,
                                        child: AutoSizeText(
                                          'Use o aplicativo e faça reservas para receber sugestões de quentinhas!',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 45.nsp,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      );

                                    return Column(
                                      children: [
                                        if (allMealsRequests.isNotEmpty)
                                          _buildOrderAgain(
                                            allMealsRequests,
                                            widget.usuario.id,
                                          ),
                                        SizedBox(height: 0.02.hp),
                                        if (filteredMealsRequests.isNotEmpty)
                                          _buildSuggestions(
                                            filteredMealsRequests,
                                          ),
                                        if (allMealsRequests.isEmpty &&
                                            filteredMealsRequests.isEmpty)
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            child: AutoSizeText(
                                              'Use o aplicativo e faça reservas para receber sugestões de quentinhas!',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 45.nsp,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 0.02.hp),
                                        if (sellerList.isNotEmpty)
                                          _buildSellers(
                                              sellerList,
                                              locationSnapshot,
                                              widget.usuario.id)
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildHeader() {
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
                    'Olá, ${widget.usuario.name.split(" ")[0]}!\nBateu a fome?',
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.montserratTextTheme(
                            Theme.of(context).textTheme)
                        .headline1,
                  ),
                ),
                SizedBox(height: 0.06.hp),
              ],
            )),
      ],
    );
  }

  Widget _buildSellers(List<Seller> sellerList,
      AsyncSnapshot<Position> locationSnapshot, String clientId) {
    return StreamBuilder(
        stream: Repository.instance.getClientStream(clientId),
        builder: (context, AsyncSnapshot<DocumentSnapshot> clientSnapshot) {
          // TODO (Gabriel): Trocar esse indicator por alguns placeholders
          if (!clientSnapshot.hasData ||
              clientSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 0.5.hp,
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ),
            );
          }
          if (clientSnapshot.hasError) {
            return Container(
              height: 0.6.hp - 56,
              alignment: Alignment.center,
              child: AutoSizeText(
                clientSnapshot.error.toString(),
                style: GoogleFonts.montserrat(
                    fontSize: 45.nsp, color: Theme.of(context).accentColor),
              ),
            );
          }

          // Ordena por sellers favoritos
          var favorites = clientSnapshot.data.data['favoriteSellers'];
          sellerList.sort((a, b) =>
              favorites.indexOf(b.id).compareTo(favorites.indexOf(a.id)));

          return SellerGridVertical(
            tagM: Random().nextDouble(),
            title: 'Vendedores',
            sellers: sellerList,
            userLocation: locationSnapshot.data,
          );
        });
  }

  Widget _buildSuggestions(List<MealRequest> meals) {
    return ListaHorizontal(
      title: 'Sugestões',
      tagM: Random().nextDouble(),
      meals: meals,
    );
  }

  Widget _buildOrderAgain(List<MealRequest> meals, String clientId) {
    return StreamBuilder(
        stream: Repository.instance.getOrdersFromClient(clientId, limit: 10),
        builder: (context, AsyncSnapshot<QuerySnapshot> orderSnapshot) {
          if (orderSnapshot.data.documents.isEmpty) {
            return Container();
          }
          if (orderSnapshot.hasError) {
            return Container(
              height: 0.6.hp - 56,
              alignment: Alignment.center,
              child: AutoSizeText(
                orderSnapshot.error.toString(),
                style: GoogleFonts.montserrat(
                    fontSize: 45.nsp, color: Theme.of(context).accentColor),
              ),
            );
          }

          var mealIds = orderSnapshot.data.documents
              .map((order) => order.data["mealId"])
              .toSet()
              .toList();
          meals.removeWhere((meal) => !mealIds.contains(meal.mealId));

          return Column(
            children: [
              ListaHorizontal(
                title: 'Peça Novamente',
                tagM: Random().nextDouble(),
                meals: meals,
              ),
            ],
          );
        });
  }
}
