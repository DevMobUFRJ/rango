import 'dart:async';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:rango/widgets/others/ModalFilter.dart';

class SearchScreen extends StatefulWidget {
  final PersistentTabController controller;
  final Seller seller;
  SearchScreen(
    this.controller, {
    this.seller,
  });

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
  CameraPosition _cameraPosition;
  String nameSeller = "";
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
            // print("la");
          },
          markerId: MarkerId(seller.location.geopoint.latitude.toString() +
              seller.location.geopoint.longitude.toString()),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          infoWindow:
              InfoWindow(title: seller.name, snippet: seller.description),
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

    //  print("localizaçao inicial: " + position.toString());
  }

  @override
  void initState() {
    super.initState();
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
    if (widget.seller != null) _returnOfSellerProfile(widget.seller);
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
            if (range != null && range.data != null) raio = range.data.toInt();
            //     print("RAIO eh " + raio.toString());
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
                              //print(snapshotSeller.error);
                              //print(snapshotSeller.stackTrace);
                              //print(snapshotSeller.data);
                              //print(snapshotSeller.toString());
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
                            _getSellersOrdered(snapshotSeller, nameSeller);
                            _carregarMarcadores(snapshotSeller);
                            return Stack(
                              children: [
                                GoogleMap(
                                  mapType: MapType.normal,
                                  initialCameraPosition: _cameraPosition,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    if (widget.seller != null) {
                                      _returnOfSellerProfile(widget.seller);
                                    }
                                    if (!_controller.isCompleted)
                                      _controller.complete(controller);
                                  },
                                  zoomControlsEnabled: false,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
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

  Widget _botaoVerVendedor(Seller seller, BuildContext context, var isOpen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.01.hp),
      width: 0.5.wp,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: isOpen ? Theme.of(context).accentColor : Colors.grey,
        ),
        onPressed: () {
          pushNewScreen(
            context,
            withNavBar: false,
            screen: SellerProfile(
              seller.id,
              seller.name,
              widget.controller,
              fromMap: true,
            ),
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          ).then((value) => _returnOfSellerProfile(value));
        },
        child: AutoSizeText(
          'Ver Mais',
          style: GoogleFonts.montserrat(
            fontSize: 36.nsp,
            color: isOpen ? null : Colors.white,
          ),
        ),
      ),
    );
  }

  void _returnOfSellerProfile(Seller seller) {
    if (seller != null &&
        seller.location != null &&
        seller.location.geopoint != null &&
        seller.location.geopoint.latitude != null &&
        seller.location.geopoint.longitude != null) {
      _gotoLocation(seller.location.geopoint.latitude,
          seller.location.geopoint.longitude);
    }
  }

  void _getSellersOrdered(
    AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller,
    String nameSeller,
  ) {
    Set<Seller> openSellers = {};
    Set<Seller> closedSellers = {};
    snapshotSeller.data.forEach((sel) {
      Seller sellerTemp = Seller.fromJson(sel.data(), id: sel.id);
      if (sellerTemp.name.toLowerCase().contains(nameSeller.toLowerCase())) {
        var openAtThisDay = _getOpenAtThisDay(sellerTemp);
        var openAtThisMoment = _getOpenAtThisMoment(sellerTemp);
        if (sellerTemp.active && openAtThisDay && openAtThisMoment) {
          openSellers.add(sellerTemp);
        } else {
          closedSellers.add(sellerTemp);
        }
      }
    });
    openSellers.addAll(closedSellers);
    allSellers = openSellers;
    if (allSellers.length == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nenhum vendedor encontrado!',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).accentColor,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  Widget _menu(BuildContext contextGeral) {
    return Positioned(
      top: 30,
      width: 50,
      child: GestureDetector(
          onTap: () => _showModal(contextGeral),
          child: Container(
            child: Icon(
              Icons.filter_alt_rounded,
              color: Theme.of(context).accentColor,
              size: ScreenUtil().setSp(80),
            ),
          )),
    );
  }

  void _showModal(contextGeral) {
    Future<void> future = menuFiltrar(contextGeral);
    future.then((dynamic value) => _closeModal(value));
  }

  void _closeModal(dynamic value) {
    // print('modal closed ');

    if (value != null && value['vendedor'] != null) {
      print('aqui:');
      print(value);
      nameSeller = value['vendedor'];
      setState(() {
        allSellers = {};
      });
    }
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
    Color cor;
    Color corTexto;
    if (isOpen) {
      cor = Colors.transparent;
      corTexto = Theme.of(context).accentColor;
    } else {
      cor = Colors.grey;
      corTexto = Colors.grey;
    }
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
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(cor, BlendMode.saturation),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      )),
                ),
              ),
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                  color: corTexto),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        _isOpen(seller),
                        _botaoVerVendedor(seller, context, isOpen)
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

    var openAtThisDay = _getOpenAtThisDay(seller);
    var openAtThisMoment = _getOpenAtThisMoment(seller);
    var isOpen;
    if (seller.active && openAtThisDay && openAtThisMoment) {
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

Widget _isOpen(Seller seller) {
  var json = seller.toJson();

  var openAtThisDay = _getOpenAtThisDay(seller);
  var openAtThisMoment = _getOpenAtThisMoment(seller);
  if (seller.active && openAtThisDay && openAtThisMoment) {
    return Container(
        child: Text(
      "Aberto",
      style: TextStyle(
          color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
    ));
  }
  String nextDayOfWeek = DateFormat('EEEE')
      .format(DateTime.now().add(Duration(days: 1)))
      .toLowerCase();
  if (json[nextDayOfWeek] == null)
    return Container(
        child: Text(
      "Sem informação de horário",
      style: TextStyle(
          color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
    ));
  var horaFormatada = json[nextDayOfWeek].openingTime.toString();
  horaFormatada = horaFormatada.padLeft(4, '0');
  horaFormatada =
      '${horaFormatada.substring(0, 2)}:${horaFormatada.substring(2, horaFormatada.length)}';
  return Container(
      child: Text(
    "Fechado \u00B7 abre $horaFormatada",
    style: TextStyle(
        color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
  ));
}

_getOpenAtThisMoment(Seller seller) {
  var json = seller.toJson();
  var date = DateTime.now();
  String dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();

  var ano = date.year;
  var mes = date.month.toString();
  if (mes.length == 1) {
    mes = "0" + mes;
  }
  var dia = date.day.toString();
  if (dia.length == 1) {
    dia = "0" + dia;
  }

  if (json[dayOfWeek] == null) return false;

  var dataString = json[dayOfWeek].openingTime.toString();
  dataString = dataString.padLeft(4, '0');
  String diaHoraFormatado =
      '${dataString.substring(0, 2)}:${dataString.substring(2, dataString.length)}';

  var dataStringfechamento = json[dayOfWeek].closingTime.toString();
  dataStringfechamento = dataStringfechamento.padLeft(4, '0');
  String diaHoraFechamentoFormatado =
      '${dataStringfechamento.substring(0, 2)}:${dataStringfechamento.substring(2, dataStringfechamento.length)}';

  String strDateAbertura = ano.toString() +
      "-" +
      mes +
      "-" +
      dia.toString() +
      " " +
      diaHoraFormatado +
      ":00";
  DateTime parseDateAbre = DateTime.parse(strDateAbertura);

  String strDateFechamento = ano.toString() +
      "-" +
      mes +
      "-" +
      dia.toString() +
      " " +
      diaHoraFechamentoFormatado +
      ":00";

  DateTime parseDateFecha = DateTime.parse(strDateFechamento);
  var openAtThisMoment =
      date.isAfter(parseDateAbre) && date.isBefore(parseDateFecha);

  return openAtThisMoment;
}

_getOpenAtThisDay(Seller seller) {
  var json = seller.toJson();
  var date = DateTime.now();
  String dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
  var openAtThisDay = json[dayOfWeek] == null ? false : json[dayOfWeek].open;
  return openAtThisDay;
}
