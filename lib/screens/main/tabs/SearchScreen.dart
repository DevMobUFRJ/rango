import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/profile/EditProfileScreen.dart';
import 'package:rango/screens/seller/SellerProfile.dart';

class SearchScreen extends StatefulWidget {
  final Client usuario;

  SearchScreen(this.usuario);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};

  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(-22.875387262850907, -43.33983922061225), zoom: 16);

  final _database = Firestore.instance;
  final geo = Geoflutterfire();

  _carregarMarcadores(Set<Seller> sellers) {
    Set<Marker> marcadoresLocal = {};

    sellers.forEach((seller) {
      Marker marcador = Marker(
          onTap: () {
            print("la");
          },
          markerId: MarkerId(seller.location.geopoint.latitude.toString() +
              seller.location.geopoint.longitude.toString()),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          infoWindow: InfoWindow(title: seller.name, snippet: "sei lá"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange));
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

  _addListenerLocalizacao() {
    Geolocator.getPositionStream().listen((Position position) {
      print("alterei a posição: " + position.toString());
    });
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  Stream<Position> _getUserLocationStream() {
    // Stream para pegar a localização da pessoa
    return Geolocator.getCurrentPosition().asStream();
  }

  Stream<QuerySnapshot> _getSellersStream() {
    // Stream para pegar os vendedores
    return _database.collection("sellers").getDocuments().asStream();
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
    });
    _movimentarCamera();

    print("localizaçao inicial: " + position.toString());
  }

  @override
  void initState() {
    super.initState();
    _recuperarLocalizacaoAtual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          _mapa(context),
        ],
      ),
    );
  }

  Widget _mapa(BuildContext contextGeral) {
    return Container(
      height: MediaQuery.of(contextGeral).size.height,
      width: MediaQuery.of(contextGeral).size.width,
      child: StreamBuilder(
        stream: _getUserLocationStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return StreamBuilder(
            stream: _getSellersStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              Set<Seller> sellers = {};
              print("vou printar os nomes aqui");
              snapshot.data.documents.forEach((seller) {
                Seller sellerC;
                sellerC = Seller.fromJson(seller.data);
                print("SELLER: " +
                    sellerC.name +
                    " LOCATION:" +
                    sellerC.location.geopoint.latitude.toString());
                sellers.add(sellerC);
              });
              _carregarMarcadores(sellers);
              return Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _cameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    markers: _marcadores,
                  ),
                  _cardsSellers(sellers, contextGeral)
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _boxes(Seller seller, BuildContext context) {
    String _image = seller.logo;
    if (_image == null) {
      _image =
          "https://folhapiaui.com.br/wp-content/uploads/2020/01/quentinha-1.jpg";
    }
    double lat = seller.location.geopoint.latitude;
    double long = seller.location.geopoint.longitude;
    String name = seller.name;

    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      onDoubleTap: () {
        print("double click");
        pushNewScreen(
          context,
          screen: SellerProfile("", seller.name),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      onLongPress: () {
        print("long press");
        pushNewScreen(
          context,
          screen: SellerProfile("", seller.name),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
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
                            SizedBox(height: 5.0),
                            Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                    child: Text(
                                  "4.1",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20.0,
                                  ),
                                )),
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.solidStar,
                                    color: Colors.amber,
                                    size: 15.0,
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.solidStar,
                                    color: Colors.amber,
                                    size: 15.0,
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.solidStar,
                                    color: Colors.amber,
                                    size: 15.0,
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.solidStar,
                                    color: Colors.amber,
                                    size: 15.0,
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    FontAwesomeIcons.solidStarHalf,
                                    color: Colors.amber,
                                    size: 15.0,
                                  ),
                                ),
                                Container(
                                    child: Text(
                                  "(946)",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                  ),
                                )),
                              ],
                            )),
                            SizedBox(height: 5.0),
                            _isOpen(seller),
                          ],
                        )),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _cardsSellers(Set<Seller> sellers, BuildContext contextGeral) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 50.0),
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

Widget _isOpen(Seller seller) {
  var date = DateTime.now();
  String dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
  print(dayOfWeek);
  var json = seller.toJson();
  print("DIA =${json[dayOfWeek]}");
  print("DIA :${json[dayOfWeek].openingTime}");

  if (seller.active) {
    return Container(
        child: Text(
      "Aberto",
      style: TextStyle(
          color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
    ));
  }
  return Container(
      child: Text(
    "Fechado \u00B7 abre ${json[dayOfWeek].openingTime}",
    style: TextStyle(
        color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
  ));
}
