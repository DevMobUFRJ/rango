import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' hide openAppSettings;
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'dart:io';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/HomeHeader.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rango/widgets/home/SellersList.dart';

class HomeScreen extends StatefulWidget {
  final Client usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _locationPermissionStatus;

  void requestForPermission() async {
    try {
      if (await Permission.location.request().isGranted) {
        setState(() {
          _locationPermissionStatus = true;
        });
      } else if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      } else {
        if (Platform.isIOS) {
          openAppSettings();
        }
        print(await Permission.location.status);
      }
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_ALREADY_REQUESTING_PERMISSIONS') {
        openAppSettings();
      }
    } catch (e) {}
  }

  void checkForPermission() async {
    if (await Permission.location.isGranted) {
      setState(() {
        _locationPermissionStatus = true;
      });
    } else
      setState(() {
        _locationPermissionStatus = false;
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_locationPermissionStatus) {
      requestForPermission();
    }
  }

  @override
  initState() {
    checkForPermission();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          child: _locationPermissionStatus == null
              ? _buildLoadingSpinnerScene()
              : !_locationPermissionStatus
                  ? _buildRequestForPermissionWidget()
                  : SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            HomeHeader(widget.usuario.name.split(" ")[0]),
                            FutureBuilder(
                              future: Repository.instance.getUserLocation(),
                              builder: (
                                context,
                                AsyncSnapshot<Position> locationSnapshot,
                              ) {
                                if (locationSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildLoadingSpinner();
                                }

                                if (locationSnapshot.hasError) {
                                  return Container(
                                    height: 0.6.hp - 56,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          locationSnapshot.error,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 45.nsp,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Consumer<RangeChangeNotifier>(
                                  builder: (context, shouldChange, child) {
                                    return FutureBuilder(
                                      future:
                                          Repository.instance.getSellerRange(),
                                      builder: (
                                        context,
                                        AsyncSnapshot<double> rangeSnapshot,
                                      ) {
                                        if (rangeSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return _buildLoadingSpinner();
                                        }
                                        if (rangeSnapshot.hasError) {
                                          return Container(
                                            height: 0.6.hp - 56,
                                            alignment: Alignment.center,
                                            child: AutoSizeText(
                                              rangeSnapshot.error.toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 45.nsp,
                                                  color: Theme.of(context)
                                                      .accentColor),
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
                                            AsyncSnapshot<
                                                    List<DocumentSnapshot>>
                                                snapshot,
                                          ) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return _buildLoadingSpinner();
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

                                            List<MealRequest> allMealsRequests =
                                                [];
                                            List<MealRequest>
                                                filteredMealsRequests = [];

                                            List<Seller> sellerList = [];
                                            snapshot.data.forEach(
                                              (sellerDoc) {
                                                Seller seller = Seller.fromJson(
                                                  sellerDoc.data,
                                                  id: sellerDoc.documentID,
                                                );
                                                sellerList.add(seller);
                                                var filterByFeatured = false;
                                                var mealsLimit = 0;
                                                var currentMeals =
                                                    seller.currentMeals;

                                                var sellerAll =
                                                    currentMeals.entries.map(
                                                  (meal) {
                                                    return MealRequest(
                                                        mealId: meal.key,
                                                        seller: seller);
                                                  },
                                                ).toList();
                                                allMealsRequests
                                                    .addAll(sellerAll);

                                                if (filterByFeatured) {
                                                  currentMeals.removeWhere(
                                                      (mealId, details) =>
                                                          !details.featured);
                                                }
                                                var sellerFiltered =
                                                    currentMeals.entries.map(
                                                  (meal) {
                                                    return MealRequest(
                                                        mealId: meal.key,
                                                        seller: seller);
                                                  },
                                                ).toList();
                                                if (mealsLimit > 0) {
                                                  sellerFiltered =
                                                      sellerFiltered
                                                          .take(mealsLimit)
                                                          .toList();
                                                }
                                                filteredMealsRequests
                                                    .addAll(sellerFiltered);
                                              },
                                            );

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
                                                  'Sem sugestões ou vendedores próximos. Aumente o alcance ou faça pedidos para receber sugestões!',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 45.nsp,
                                                    color: Theme.of(context)
                                                        .accentColor,
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
                                                if (filteredMealsRequests
                                                    .isNotEmpty)
                                                  _buildSuggestions(
                                                    filteredMealsRequests,
                                                  ),
                                                if (allMealsRequests.isEmpty &&
                                                    filteredMealsRequests
                                                        .isEmpty)
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10,
                                                    ),
                                                    child: AutoSizeText(
                                                      'Use o aplicativo e faça reservas para receber sugestões de quentinhas!',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        fontSize: 45.nsp,
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(height: 0.02.hp),
                                                if (sellerList.isNotEmpty)
                                                  SellersList(
                                                      sellerList,
                                                      locationSnapshot,
                                                      widget.usuario.id),
                                                if (sellerList.isEmpty)
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 10,
                                                    ),
                                                    child: AutoSizeText(
                                                      'Aumente o alcance para visualizar vendedores!',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        fontSize: 45.nsp,
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                      ),
                                                    ),
                                                  ),
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
        ),
      ),
    );
  }

  Widget _buildLoadingSpinner() {
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

  Widget _buildLoadingSpinnerScene() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HomeHeader(widget.usuario.name.split(" ")[0]),
        Container(
          height: 0.5.hp,
          alignment: Alignment.center,
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: Theme.of(context).accentColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRequestForPermissionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HomeHeader(widget.usuario.name.split(" ")[0]),
        SizedBox(height: 0.1.hp),
        AutoSizeText(
          'É necessário dar permissão de localização para utilizar o aplicativo',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 45.nsp,
            color: Theme.of(context).accentColor,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            onPressed: () => requestForPermission(),
            child: AutoSizeText(
              'Dar permissão',
              style: GoogleFonts.montserrat(
                fontSize: 35.nsp,
              ),
            ),
          ),
        )
      ],
    );
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
        if (orderSnapshot.connectionState == ConnectionState.waiting) {
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
        meals.removeWhere(
          (meal) => !mealIds.contains(meal.mealId),
        );

        return Column(
          children: [
            ListaHorizontal(
              title: 'Peça Novamente',
              tagM: Random().nextDouble(),
              meals: meals,
            ),
          ],
        );
      },
    );
  }
}
