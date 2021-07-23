import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/widgets/others/ModalFilter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

class NewSearchScreen extends StatefulWidget {
  final PersistentTabController tabController;
  final Seller seller;

  NewSearchScreen(
    this.tabController, {
    this.seller,
  });

  @override
  _NewSearchScreenState createState() => _NewSearchScreenState();
}

class _NewSearchScreenState extends State<NewSearchScreen> {
  bool _isLoading = true;
  bool _isCardsLoading = true;
  double _sellerRange;
  Position _userLocation;
  CameraPosition _cameraPosition;

  Set<Marker> _marcadores = {};

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  double _customInfoWindowHeight = 100;
  double _customInfoWindowWidth = 150;

  String _filter = '';
  bool _filterMarker = false;

  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  BitmapDescriptor customMarkerIcon;

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
    _getSellerRange();
    super.initState();
  }

  _setCustomMarkers() async {
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/imgs/pinMapa.png');
  }

  _getSellerRange() async {
    double sellerRange = await Repository.instance.getSellerRange();
    setState(() => _sellerRange = sellerRange);
    await _getUserLocation();
  }

  _getUserLocation() async {
    Position userLocation = await Repository.instance.getUserLocation();
    setState(() => {
          _userLocation = userLocation,
          _isLoading = false,
          _filterMarker = true,
        });
    List<Seller> sellsers =
        await Repository.instance.getNearbySellers(userLocation, _sellerRange);
    print('alibaba');
    print('alibaba: $sellsers');
    sellsers.forEach((element) {
      print('alibaba: ${element.name}');
    });
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() => _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        ));
    _movimentarCamera();
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController =
        await _mapControllerCompleter.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_cameraPosition),
    );
  }

  List<Seller> _mapSellers(
      AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller) {
    print('vtnc porra');
    List<Seller> sellerList = [];
    snapshotSeller.data.forEach(
      (sel) {
        Seller seller = Seller.fromJson(sel.data(), id: sel.id);

        if (_filter.length == 0) {
          sellerList.add(seller);
        } else {
          if (seller.name.toLowerCase().contains(_filter.toLowerCase())) {
            sellerList.add(seller);
          }
        }
      },
    );
    if (sellerList.isEmpty) {
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
    if ((_marcadores.length == 0 && sellerList.length > 0) ||
        _filterMarker == true) {
      print('vtnc');
      _carregarMarcadores(sellerList);
    }
    return sellerList;
  }

  Widget _buildLoadingSpinner() {
    return Container(
      height: 1.hp - 56,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Carregando o mapa',
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

  Widget _buildError(String error) {
    return Container(
      height: 0.6.hp - 56,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            error,
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

  Widget _cardsSellers(List<Seller> sellers, BuildContext contextGeral) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 150.0,
        child: ScrollablePositionedList.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sellers.length,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 8),
              child: _boxes(sellers.elementAt(index), contextGeral, index),
            );
          },
        ),
      ),
    );
  }

  Widget _boxes(Seller seller, BuildContext context, int index) {
    double lat = seller.location.geopoint.latitude;
    double long = seller.location.geopoint.longitude;

    return GestureDetector(
      onTap: () async {
        _customInfoWindowController.hideInfoWindow();
        await _gotoLocation(lat, long);
        _customInfoWindowController.addInfoWindow(
          Material(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Theme.of(context).accentColor,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: _customInfoWindowHeight,
                maxWidth: _customInfoWindowWidth,
              ),
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 3,
                    child: AutoSizeText(
                      seller.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 32.nsp,
                      ),
                    ),
                  ),
                  if (seller.description != null) ...{
                    SizedBox(height: 5),
                    Flexible(
                      flex: 2,
                      child: AutoSizeText(
                        seller.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 28.nsp,
                        ),
                      ),
                    ),
                  }
                ],
              ),
            ),
          ),
          LatLng(
            seller.location.geopoint.latitude,
            seller.location.geopoint.longitude,
          ),
        );
        await _itemScrollController.scrollTo(
          index: index,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 300),
        );
      },
      child: _box(seller, context, seller.isOpen()),
    );
  }

  //

  Widget _box(Seller seller, BuildContext context, bool isOpen) {
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
          elevation: 2,
          borderRadius: BorderRadius.circular(24.0),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long, {double zoom}) async {
    print('cusao');
    final GoogleMapController controller = await _mapControllerCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: zoom != null ? zoom : 15,
        ),
      ),
    );
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
              widget.tabController,
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

  Widget _menu(BuildContext contextGeral) {
    return Positioned(
      bottom: 156,
      right: 5,
      width: 50,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _gotoLocation(
                _userLocation.latitude,
                _userLocation.longitude,
                zoom: 16,
              );
              _customInfoWindowController.hideInfoWindow();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 2,
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
                    blurRadius: 2,
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

  Future<void> _closeModal(dynamic value) async {
    if (value != null) {
      if (value['vendedor'] != null &&
          value['changedRange'] != null &&
          value['changedRange'] == true) {
        double sellerRange = await Repository.instance.getSellerRange();
        setState(() {
          _filter = value['vendedor'];
          _filterMarker = true;
          _sellerRange = sellerRange;
        });
      } else {
        if (value['vendedor'] != null) {
          setState(() => {
                _filterMarker = true,
                _filter = value['vendedor'],
              });
        }
        if (value['changedRange'] != null && value['changedRange'] == true) {
          _getSellerRange();
        }
      }
    } else {
      setState(() {
        _filter = '';
        _filterMarker = true;
      });
    }
  }

  menuFiltrar(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(child: ModalFilter(_sellerRange.toInt()));
        });
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

  _carregarMarcadores(List<Seller> sellers) async {
    Set<Marker> marcadoresLocal = {};
    sellers.toList().asMap().forEach(
      (index, seller) {
        Marker marcador = Marker(
          onTap: () async {
            await _itemScrollController.scrollTo(
              index: index,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 300),
            );
            await _gotoLocation(
              seller.location.geopoint.latitude,
              seller.location.geopoint.longitude,
              zoom: 16,
            );
            _customInfoWindowController.addInfoWindow(
              GestureDetector(
                onTap: () {
                  pushNewScreen(
                    context,
                    withNavBar: false,
                    screen: SellerProfile(
                      seller.id,
                      seller.name,
                      widget.tabController,
                      fromMap: true,
                    ),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ).then((value) => _returnOfSellerProfile(value));
                },
                child: Material(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Theme.of(context).accentColor,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: _customInfoWindowHeight,
                      maxWidth: _customInfoWindowWidth,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          flex: 3,
                          child: AutoSizeText(
                            seller.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 32.nsp,
                            ),
                          ),
                        ),
                        if (seller.description != null) ...{
                          SizedBox(height: 5),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(
                              seller.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 28.nsp,
                              ),
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                ),
              ),
              LatLng(
                seller.location.geopoint.latitude,
                seller.location.geopoint.longitude,
              ),
            );
          },
          markerId: MarkerId(seller.location.geopoint.latitude.toString() +
              seller.location.geopoint.longitude.toString()),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          // infoWindow: InfoWindow(
          //   title: seller.name,
          //   snippet: seller.description,
          //   onTap: () {
          //     print('oi');
          //   },
          // ),
          icon: customMarkerIcon,
          consumeTapEvents: true,
        );
        marcadoresLocal.add(marcador);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _filterMarker = false;
        _marcadores = marcadoresLocal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _isLoading
          ? _buildLoadingSpinner()
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _cameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_mapControllerCompleter.isCompleted) {
                      _mapControllerCompleter.complete(controller);
                    }
                    _customInfoWindowController.googleMapController =
                        controller;
                  },
                  onTap: (_) {
                    _customInfoWindowController.hideInfoWindow();
                  },
                  onCameraMove: (pos) {
                    _customInfoWindowController.onCameraMove();
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  markers: _marcadores,
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: _customInfoWindowHeight,
                  width: _customInfoWindowWidth,
                  offset: 50,
                ),
                StreamBuilder(
                  stream: Repository.instance.getNearbySellersStream(
                    _userLocation,
                    _sellerRange,
                    queryByActive: false,
                    queryByTime: false,
                  ),
                  builder: (BuildContext sellerSnapshotContext,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshotSeller) {
                    if (snapshotSeller.connectionState ==
                        ConnectionState.waiting) return SizedBox();
                    //TODO carregamento dos cards

                    if (snapshotSeller.hasError) return SizedBox();

                    List<Seller> sellers = _mapSellers(snapshotSeller);
                    return _cardsSellers(sellers, sellerSnapshotContext);
                  },
                ),
                _menu(context),
              ],
            ),
    );
  }
}
