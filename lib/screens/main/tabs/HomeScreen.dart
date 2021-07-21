import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'dart:io';
import 'package:rango/resources/rangeChangeNotifier.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/profile/ProfileSettings.dart';
import 'package:rango/widgets/home/HomeHeader.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rango/widgets/home/SellersList.dart';

class HomeScreen extends StatefulWidget {
  final Client usuario;
  final PersistentTabController controller;
  HomeScreen(this.usuario, this.controller, {Key key}) : super(key: key);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _locationPermissionStatus;
  bool _locationPermissionLoading = false;
  bool _showFillPerfil = true;

  void requestForPermission() async {
    try {
      setState(() => _locationPermissionLoading = true);
      bool locationPermission =
          await Permission.locationWhenInUse.request().isGranted;
      bool locationWhenUsePermission =
          await Permission.location.request().isGranted;
      if (locationPermission || locationWhenUsePermission) {
        setState(() {
          _locationPermissionStatus = true;
          _locationPermissionLoading = false;
        });
      } else if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
        setState(() => _locationPermissionLoading = false);
      } else if (await Permission.location.status.isDenied ||
          await Permission.locationWhenInUse.status.isDenied) {
        if (Platform.isIOS) {
          openAppSettings();
          setState(() => _locationPermissionLoading = false);
        } else {
          setState(() => {
                _locationPermissionStatus = false,
                _locationPermissionLoading = false
              });
        }
      }
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_ALREADY_REQUESTING_PERMISSIONS') {
        setState(() => _locationPermissionLoading = false);
      }
    } catch (e) {
      setState(() => _locationPermissionLoading = false);
    }
  }

  void checkForPermission() async {
    if (await Permission.location.isGranted) {
      setState(() {
        _locationPermissionStatus = true;
        _locationPermissionLoading = false;
      });
    } else
      setState(() {
        _locationPermissionStatus = false;
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_locationPermissionStatus) {
      checkForPermission();
    }
  }

  @override
  initState() {
    checkForPermission();
    _checkInternet();
    _checkFillPerfil();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _checkFillPerfil() async {
    bool fillPerfil = await Repository.instance.showFillPerfil();
    setState(() => _showFillPerfil = fillPerfil);
  }

  Future<void> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Repository.instance.setInternetConnection(true, context);
        return true;
      } else
        return false;
    } on SocketException catch (_) {
      Repository.instance.setInternetConnection(false, context);
      return true;
    }
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
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          HomeHeader(
                            widget.usuario.name.contains(' ')
                                ? widget.usuario.name.split(' ')[0]
                                : widget.usuario.name,
                          ),
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
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        locationSnapshot.error,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 45.nsp,
                                          color: Theme.of(context).accentColor,
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
                                          //TODO Mudar para true quando acabar os testes
                                          queryByActive: false,
                                          queryByTime: false,
                                        ),
                                        builder: (
                                          ctxNearbySellers,
                                          AsyncSnapshot<List<DocumentSnapshot>>
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
                                                  color:
                                                      Theme.of(ctxNearbySellers)
                                                          .accentColor,
                                                ),
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
                                                sellerDoc.data(),
                                                id: sellerDoc.id,
                                              );
                                              sellerList.add(seller);
                                              var filterByFeatured = true;
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
                                                sellerFiltered = sellerFiltered
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
                                                'Sem sugestões ou vendedores próximos abertos. Você pode aumentar o alcance ou fazer pedidos para receber sugestões!',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 45.nsp,
                                                  color:
                                                      Theme.of(ctxNearbySellers)
                                                          .accentColor,
                                                ),
                                              ),
                                            );

                                          return Column(
                                            children: [
                                              _buildFillProfileSuggestions(),
                                              if (allMealsRequests.isNotEmpty)
                                                _buildOrderAgain(
                                                  allMealsRequests,
                                                  widget.usuario.id,
                                                ),
                                              if (filteredMealsRequests
                                                  .isNotEmpty)
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 45.nsp,
                                                      color: Theme.of(
                                                              ctxNearbySellers)
                                                          .accentColor,
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(height: 0.02.hp),
                                              if (sellerList.isNotEmpty)
                                                SellersList(
                                                  sellerList,
                                                  locationSnapshot,
                                                  widget.usuario,
                                                  widget.controller,
                                                ),
                                              if (sellerList.isEmpty)
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 10,
                                                  ),
                                                  child: AutoSizeText(
                                                    'Aumente o alcance para visualizar vendedores!',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 45.nsp,
                                                      color: Theme.of(
                                                              ctxNearbySellers)
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
        HomeHeader(
          widget.usuario.name.contains(' ')
              ? widget.usuario.name.split(' ')[0]
              : widget.usuario.name,
        ),
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

  Widget _buildFillProfileSuggestions() {
    Client usuario = widget.usuario;
    String textToShow = '';
    if (usuario.picture == null || usuario.picture.isEmpty)
      textToShow += '\n- Adicione uma foto de perfil;';
    if (usuario.notificationSettings == null)
      textToShow +=
          '\n- Escolha as configurações de notificações no seu perfil;';
    return textToShow.length == 0
        ? SizedBox()
        : FutureBuilder(
            future: Repository.instance.showFillPerfil(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError) return SizedBox();
              if (snapshot.hasData && snapshot.data == false) return SizedBox();
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () => widget.controller.jumpToTab(3),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 0.01.hp, vertical: 10),
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Theme.of(context).accentColor,
                          elevation: 5,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Você ainda não completou seu perfil:$textToShow',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 28.nsp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Repository.instance.dontShowFillPerfill();
                        Provider.of<RangeChangeNotifier>(context, listen: false)
                            .triggerRefresh();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.red[400],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildRequestForPermissionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HomeHeader(
          widget.usuario.name.contains(' ')
              ? widget.usuario.name.split(' ')[0]
              : widget.usuario.name,
        ),
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
            onPressed: _locationPermissionLoading
                ? null
                : () => requestForPermission(),
            child: _locationPermissionLoading
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.15.wp),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    width: 0.4.wp,
                    child: AutoSizeText(
                      'Dar permissão',
                      style: GoogleFonts.montserrat(
                        fontSize: 35.nsp,
                      ),
                      textAlign: TextAlign.center,
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
      controller: widget.controller,
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
        if (orderSnapshot.data.docs.isEmpty) {
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

        var mealIds = orderSnapshot.data.docs
            .map((order) => order.get("mealId"))
            .toSet()
            .toList();
        meals.removeWhere(
          (meal) => !mealIds.contains(meal.mealId),
        );
        if (meals.isNotEmpty) {
          return Column(
            children: [
              ListaHorizontal(
                title: 'Peça Novamente',
                tagM: Random().nextDouble(),
                meals: meals,
                controller: widget.controller,
              ),
              SizedBox(height: 0.02.hp),
            ],
          );
        } else
          return Container();
      },
    );
  }
}
