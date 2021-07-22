import 'dart:async';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/utils/constants.dart';
import 'dart:ui' as ui;
import 'package:rango/widgets/others/ModalFilter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool _isFiltering = false;
  Set<Seller> allSellers = {};
  Set<Marker> _marcadores;
  int raio;
  BitmapDescriptor marMarkerCustom;
  Position userLocation;
  CameraPosition _cameraPosition;
  String nameSeller = "";
  final geo = Geoflutterfire();

  void _setCustomMarkers() async {
    marMarkerCustom = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/imgs/pinMapa.png');
  }

  _carregarMarcadores(
      AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller) async {
    Set<Marker> marcadoresLocal = {};
    snapshotSeller.data.asMap().forEach(
      (index, sellerTemp) {
        Seller seller = Seller.fromJson(sellerTemp.data(), id: sellerTemp.id);
        Marker marcador = Marker(
          onTap: () async {
            print(index);
            itemScrollController.scrollTo(
              index: index,
              duration: Duration(milliseconds: 300),
            );
          },
          markerId: MarkerId(seller.location.geopoint.latitude.toString() +
              seller.location.geopoint.longitude.toString()),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          infoWindow:
              InfoWindow(title: seller.name, snippet: seller.description),
          icon: marMarkerCustom,
        );
        marcadoresLocal.add(marcador);
      },
    );
    _marcadores = marcadoresLocal;
  }

  Future<void> _gotoLocation(double lat, double long, {double zoom}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: zoom != null ? zoom : 15,
        ),
      ),
    );
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
      height: 1.hp - 56,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isFiltering ? 'Filtrando os vendedores' : 'Carregando o mapa',
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 35.nsp,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Theme.of(context).accentColor,
              strokeWidth: 3,
            ),
          ),
        ],
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
                      AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller,
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
                      _getSellersOrdered(snapshotSeller, nameSeller);
                      _carregarMarcadores(snapshotSeller);
                      return Stack(
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _cameraPosition,
                            onMapCreated: (GoogleMapController controller) {
                              if (widget.seller != null) {
                                _returnOfSellerProfile(widget.seller);
                              }
                              if (!_controller.isCompleted)
                                _controller.complete(controller);
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            markers: _marcadores,
                          ),
                          _cardsSellers(allSellers, contextGeral),
                          _menu(contextGeral)
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _botaoVerVendedor(Seller seller, BuildContext context, var isOpen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.01.hp),
      width: 0.4.wp,
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
            fontSize: 38.nsp,
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
        if (sellerTemp.isOpen()) {
          openSellers.add(sellerTemp);
        } else {
          closedSellers.add(sellerTemp);
        }
      }
    });
    openSellers.addAll(closedSellers);
    allSellers = openSellers;
    if (allSellers.length == 0) {
      _isFiltering = false;
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
      bottom: 156,
      right: 5,
      width: 50,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _gotoLocation(
              userLocation.latitude,
              userLocation.longitude,
              zoom: 16,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.my_location,
                  color: Theme.of(context).accentColor,
                  size: 35,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showModal(contextGeral),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.filter_alt_rounded,
                  color: Theme.of(context).accentColor,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
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
        _isFiltering = true;
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
                    child: seller.logo == null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 200,
                                color: Theme.of(context).accentColor,
                              ),
                              Center(
                                child: Icon(
                                  Icons.store,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: seller.logo,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Stack(
                              alignment: Alignment.center,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Color.fromRGBO(255, 175, 153, 1),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    height: 200,
                                    color: Colors.white,
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.store,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            errorWidget: (ctx, url, error) => Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 200,
                                  color: Theme.of(context).accentColor,
                                ),
                                Center(
                                  child: Icon(
                                    Icons.store,
                                    size: 75,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
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
          ),
        ),
      ),
    );
  }

  Widget _boxes(Seller seller, BuildContext context) {
    double lat = seller.location.geopoint.latitude;
    double long = seller.location.geopoint.longitude;

    var isOpen;
    if (seller.isOpen()) {
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
        child: ScrollablePositionedList.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sellers.length,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
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
  if (seller.isOpen()) {
    return Container(
        child: Text(
      "Aberto",
      style: TextStyle(
          color: Colors.black54, fontSize: 22.0, fontWeight: FontWeight.bold),
    ));
  }

  String thisWeekday = weekdayMap[DateTime.now().weekday];
  List<String> weekdays = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ];
  List<String> weekdaysFromNow =
      weekdays.skip(weekdays.indexOf(thisWeekday) + 1).toList() + weekdays;
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
      horaFormatada =
          '${horaFormatada.substring(0, 2)}:${horaFormatada.substring(2, 4)}';
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
      "Fechado\nAbre $weekdayFound às $horaFormatada",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black54,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
