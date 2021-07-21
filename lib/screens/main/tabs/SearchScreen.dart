import 'dart:async';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/utils/date_time.dart';
import 'dart:ui' as ui;
import 'package:rango/widgets/others/ModalFilter.dart';

class SearchScreen extends StatefulWidget {
  final Client usuario;
  PersistentTabController controller;
  SearchScreen(this.usuario);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Seller> allSellers = {};
  Set<Marker> _marcadores = {};
  int raio;
  BitmapDescriptor marMarkerCustom;
  Position userLocation;
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(-22.875387262850907, -43.33983922061225), zoom: 16);

  final geo = Geoflutterfire();
  void _setCustomMarkers() async {
    // getBytesFromAsset('assets/imgs/map2.png', 64)
    //     .then((value) => {marMarkerCustom = BitmapDescriptor.fromBytes(value)});
    marMarkerCustom = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/imgs/iconeRoxo.png');
  }

  _carregarMarcadores(
      AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller) async {
    Set<Marker> marcadoresLocal = {};

    snapshotSeller.data.forEach((sellerTemp) {
      Seller seller = Seller.fromJson(sellerTemp.data(), id: sellerTemp.id);
      Marker marcador = Marker(
          onTap: () {
            print("la");
          },
          markerId: MarkerId(seller.location.geopoint.latitude.toString() +
              seller.location.geopoint.longitude.toString()),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          infoWindow: InfoWindow(title: seller.name, snippet: seller.description),
          icon: marMarkerCustom);
      marcadoresLocal.add(marcador);
    });
    _marcadores = marcadoresLocal;
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      //    tilt: 50.0,
      // bearing: 45.0,
    )));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  Stream<List<DocumentSnapshot>> getNearbySellersStream(
      Position userLocation, double radius) {

      return Repository.instance.getNearbySellersStream(
        userLocation,
        radius,
        queryByActive: false,
        queryByTime: false,
      );

  }

   _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
    });
    _movimentarCamera();
  }

  @override
  void initState() {
    super.initState();
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
  }

  @override
  Widget build(BuildContext context) {
    //_getSellersStream();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          _mapa(context),
        ],
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

  Widget _mapa(BuildContext contextGeral) {
    return Container(
      height: MediaQuery.of(contextGeral).size.height,
      width: MediaQuery.of(contextGeral).size.width,
      child: FutureBuilder(
          future: Repository.instance.getSellerRange(),
          builder: (BuildContext context, AsyncSnapshot<double> range) {
            if (range.hasData) {
              raio = range.data.toInt();
            }

            return Container(
              height: 1.hp - 56,
              child: RefreshIndicator(
                onRefresh: () {
                  setState(() {});
                  return Future.value();
                },
                child: FutureBuilder(
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
                      userLocation = locationSnapshot.data;
                      return StreamBuilder(
                          stream: getNearbySellersStream(
                              locationSnapshot.data, range.data),
                          builder: (
                            context,
                            AsyncSnapshot<List<DocumentSnapshot>>
                                snapshotSeller,
                          ) {
                            if (snapshotSeller.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingSpinner();
                            }
                            if (snapshotSeller.hasError) {
                              print(snapshotSeller.error);
                              return Container(
                                height: 0.6.hp - 56,
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  snapshotSeller.error.toString(),
                                  style: GoogleFonts.montserrat(
                                      fontSize: 45.nsp,
                                      color: Theme.of(context).accentColor),
                                ),
                              );
                            }

                            _getSellersOrdered(snapshotSeller);
                            _carregarMarcadores(snapshotSeller);
                            return Stack(
                              children: [
                                GoogleMap(
                                  mapType: MapType.normal,
                                  initialCameraPosition: _cameraPosition,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                  zoomControlsEnabled: false,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  markers: _marcadores,
                                ),
                                _cardsSellers(allSellers, contextGeral),
                                _menu(contextGeral)
                              ],
                            );
                          });
                    }),
              ),
            );
          }),
    );
  }

  _getSellersOrdered(AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller) {
    Set<Seller> openSellers = {};
    Set<Seller> closedSellers = {};

    snapshotSeller.data.forEach((sel) {
      Seller sellerTemp = Seller.fromJson(sel.data(), id: sel.id);
      var openAtThisMoment = _getOpenAtThisMoment(sellerTemp);

      if (sellerTemp.active && openAtThisMoment) {
        openSellers.add(sellerTemp);
      } else {
        closedSellers.add(sellerTemp);
      }
    });
    openSellers.addAll(closedSellers);

    allSellers = openSellers;
  }

  Widget _menu(BuildContext contextGeral) {
    return Positioned(
      top: 30,
      width: 50,
      child: GestureDetector(
        onTap: () => _showModal(contextGeral),
        child: Icon(
          Icons.menu,
          color: Theme.of(context).accentColor,
          size: ScreenUtil().setSp(60),
        ),
      ),
    );
  }

  void _showModal(contextGeral) {
    Future<void> future = menuFiltrar(contextGeral);
    future.then((dynamic value) => _closeModal(value));
  }

  void _closeModal(dynamic value) {
    //getNearbySellersStream(userLocation, raio.toDouble(), value['vendedor']);
  }

  menuFiltrar(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(child: ModalFilter(raio));
        });
  }

  Widget _box(Seller seller, BuildContext context, var isOpen) {
    String name = seller.name;
    String _image = seller.logo;
    return Container(
        child: new FittedBox(
      child: Material(
          color: Colors.white,
          elevation: 14.0,
          borderRadius: BorderRadius.circular(24.0),
          shadowColor: Color(0x802196F3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 180,
                height: 200,
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(24.0),
                  child: Image(
                    fit: BoxFit.fill,
                    image: NetworkImage(_image),
                  ),
                ),
              ),
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    //child: myDetailsContainer1(name),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            child: AutoSizeText(
                              name,
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        _isOpen(seller),
                        _botaoVerVendedor(seller, context)
                      ],
                    )),
              ),
            ],
          )),
    ));
  }

  Widget _boxes(Seller seller, BuildContext context) {
    double lat = seller.location.geopoint.latitude;
    double long = seller.location.geopoint.longitude;

    var openAtThisMoment = _getOpenAtThisMoment(seller);
    var isOpen;
    if (seller.active && openAtThisMoment) {
      isOpen = true;
      return GestureDetector(
        onTap: () {
          _gotoLocation(lat, long);
        },
        child: _box(seller, context, isOpen),
      );
    }
    isOpen = false;
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: _box(seller, context, isOpen),
    );
  }

  Widget _cardsSellers(Set<Seller> sellers, BuildContext contextGeral) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        height: 150.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sellers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(sellers.elementAt(index), contextGeral),
            );
          },
        ),
      ),
    );
  }
}

Widget _botaoVerVendedor(Seller seller, BuildContext context) {
  PersistentTabController controller;
  return Container(
    margin: EdgeInsets.symmetric(vertical: 0.01.hp),
    width: 0.5.wp,
    child: RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 0.01.hp, horizontal: 0.1.wp),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onPressed: () {
        pushNewScreen(
          context,
          withNavBar: false,
          screen: SellerProfile(seller.id, seller.name, controller),
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: AutoSizeText(
        'Ver Mais',
        style: GoogleFonts.montserrat(
          fontSize: 36.nsp,
        ),
      ),
    ),
  );
}

Widget _isOpen(Seller seller) {
  var openAtThisMoment = _getOpenAtThisMoment(seller);
  if (seller.active && openAtThisMoment) {
    return Container(
        child: Text(
      "Aberto",
      style: TextStyle(
          color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
    ));
  }

  String thisWeekday = weekdayMap[DateTime.now().weekday];
  List<String> weekdays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  List<String> weekdaysFromNow = weekdays.skip(weekdays.indexOf(thisWeekday)+1).toList() + weekdays;
  bool found = false;
  String weekdayFound = '';
  String horaFormatada = '';

  for (String day in weekdaysFromNow) {
    if (seller.shift[day] != null &&
        seller.shift[day].open &&
        seller.shift[day].openingTime != null) {
      found = true;
      horaFormatada = seller.shift[day].openingTime.toString();
      horaFormatada = horaFormatada.padLeft(4, '0');
      horaFormatada = '${horaFormatada.substring(0, 2)}:${horaFormatada.substring(2, 4)}';
      weekdayFound = weekdayTranslate[day];
      break;
    }
  }

  if (found == false && horaFormatada != '') {
    return Container(
        child: Text(
          "Sem informação de horário",
          style: TextStyle(
              color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
        ));
  }

  return Container(
      child: Text(
    "Fechado \u00B7 abre $weekdayFound $horaFormatada",
    style: TextStyle(
        color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
  ));
}

_getOpenAtThisMoment(Seller seller) {
  DateTime now = DateTime.now();
  String dayOfWeek = weekdayMap[now.weekday];

  if (seller.shift[dayOfWeek] == null) return false;
  if (seller.shift[dayOfWeek].open == false) return false;

  TimeOfDay openingTime = intTimeToTimeOfDay(seller.shift[dayOfWeek].openingTime);
  TimeOfDay closingTime = intTimeToTimeOfDay(seller.shift[dayOfWeek].closingTime);

  if (openingTime == null || closingTime == null) return false;

  DateTime openingDate = DateTime(now.year, now.month, now.day, openingTime.hour, openingTime.minute);
  DateTime closingDate = DateTime(now.year, now.month, now.day, closingTime.hour, closingTime.minute);
  print(seller.name);
  print(openingDate);
  print(closingDate);

  return now.isAfter(openingDate) && now.isBefore(closingDate);
}