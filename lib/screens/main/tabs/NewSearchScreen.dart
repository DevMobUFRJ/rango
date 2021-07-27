import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/widgets/others/CustomMarker.dart';
import 'package:rango/widgets/others/ModalFilter.dart';
import 'package:rango/widgets/others/marker_generator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

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

class _NewSearchScreenState extends State<NewSearchScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  double _sellerRange;
  Position _userLocation;
  bool _loadingMyLocation = false;
  CameraPosition _cameraPosition;
  CameraPosition _sellerPosition;
  List<Seller> _allSellers;
  bool _isCardsLoading = false;
  Set<Marker> _marcadores = {};
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  double _customInfoWindowHeight = 200.h;
  double _customInfoWindowWidth = 250.h;
  String _filter = '';
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  BitmapDescriptor customMarkerIcon;
  String _mapStyle =
      "[{\"featureType\": \"poi\",\"stylers\": [{ \"visibility\": \"off\" }]}]";
  var sellersSubscription;

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    sellersSubscription.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        var controller = await _mapControllerCompleter.future;
        controller.setMapStyle("[]");
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
    _loadData();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
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

                    controller.setMapStyle(_mapStyle);
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
                _cardsSellers(_allSellers, context),
                if (widget.seller != null) _buildBackButton(context),
                _buildFloatingButtons(context),
              ],
            ),
    );
  }

  _setCustomMarkers() async {
    /*
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/imgs/pinMapa.png'
    );*/

    MarkerGenerator([CustomMarker()], (bitmaps) {
      if (bitmaps.isNotEmpty) {
        customMarkerIcon = BitmapDescriptor.fromBytes(bitmaps.first);
      }
    }).generate(context);
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _userLocation = position;
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      );
      if (widget.seller != null)
        _sellerPosition = CameraPosition(
          target: LatLng(
            widget.seller.location.geopoint.latitude,
            widget.seller.location.geopoint.longitude,
          ),
          zoom: 16,
        );
    });

    _movimentarCamera(widget.seller != null);
  }

  _loadData() async {
    double sellerRange = await Repository.instance.getSellerRange();
    Position userLocation = await Repository.instance.getUserLocation();

    sellersSubscription = Repository.instance
        .getNearbySellersStream(userLocation, sellerRange)
        .listen((docsList) {
          List<Seller> allSellers = docsList.map((doc) => Seller.fromJson(doc.data(), id: doc.id)).toList();

          List<Seller> sellers = _mapSellers(allSellers);
          Set<Marker> marcadores = _carregarMarcadores(sellers);
          setState(() => {
            _userLocation = userLocation,
            _isLoading = false,
            _allSellers = sellers,
            _sellerRange = sellerRange,
            _marcadores = marcadores,
            _isCardsLoading = false,
          });
        });

    if (widget.seller != null) {
      await _mapControllerCompleter.future;
      _customInfoWindowController.hideInfoWindow();
      _customInfoWindowController.addInfoWindow(
        _buildInfoWindow(
          _customInfoWindowHeight,
          _customInfoWindowWidth,
          widget.seller,
          context,
        ),
        LatLng(
          widget.seller.location.geopoint.latitude,
          widget.seller.location.geopoint.longitude,
        ),
      );
    }
  }

  _updateUserLocation() async {
    try {
      Position userLocation = await Repository.instance.getUserLocation();
      setState(() {
        _userLocation = userLocation;
        _loadingMyLocation = false;
      });
      _goToLocation(
        userLocation.latitude,
        userLocation.longitude,
        zoom: 16,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Erro ao pegar localização do usuário',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  List<Seller> _mapSellers(List<Seller> sellersToMap) {
    List<Seller> sellers = [];
    if (_filter == '') {
      sellers = sellersToMap;
    } else {
      sellersToMap.forEach((sel) {
        if (sel.name.toLowerCase().contains(_filter.toLowerCase())) {
          sellers.add(sel);
        }
      });
    }

    if (sellers.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Não foram encontrados vendedores!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).accentColor,
        ),
      );
    } else {
      sellers.sort((s1, s2) =>
          _getDistanceSellerToUser(s1).compareTo(_getDistanceSellerToUser(s2)));
      sellers.sort(
        (s1, s2) => s1.isOpen() == s2.isOpen()
            ? 0
            : s1.isOpen() && !s2.isOpen()
                ? -1
                : 1,
      );
    }
    return sellers;
  }

  double _getDistanceSellerToUser(Seller seller) {
    if (_userLocation == null ||
        _userLocation.latitude == null ||
        _userLocation.longitude == null) return 1;
    return Geolocator.distanceBetween(
        seller.location.geopoint.latitude,
        seller.location.geopoint.longitude,
        _userLocation.latitude,
        _userLocation.longitude);
  }

  _movimentarCamera(bool hasSeller) async {
    GoogleMapController googleMapController =
        await _mapControllerCompleter.future;
    if (hasSeller) {
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(_sellerPosition),
      );
    } else {
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(_cameraPosition),
      );
    }
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

  Widget _buildSellersLoading() {
    return Center(
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AutoSizeText(
            'Carregando vendedores...',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 32.nsp,
            ),
          ),
        ),
        color: Theme.of(context).accentColor,
        elevation: 3,
      ),
    );
  }

  Widget _cardsSellers(List<Seller> sellers, BuildContext contextGeral) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        height: 285.nsp,
        child: _isCardsLoading
            ? _buildSellersLoading()
            : ScrollablePositionedList.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sellers.length,
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                initialScrollIndex: _getSellerIndex(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 8, right: 8, bottom: 8, left: 8),
                    child: _buildSellerCard(
                      sellers[index],
                      contextGeral,
                      index,
                    ),
                  );
                },
              ),
      ),
    );
  }

  int _getSellerIndex() {
    if (widget.seller == null) return 0;
    var index =
        _allSellers.indexWhere((seller) => seller.id == widget.seller.id);
    if (index == -1)
      return 0;
    else
      return index;
  }

  Widget _buildSellerCard(Seller seller, BuildContext context, int index) {
    double lat = seller.location.geopoint.latitude;
    double long = seller.location.geopoint.longitude;

    return GestureDetector(
      onTap: () async {
        await _goToLocation(lat, long);
        _customInfoWindowController.addInfoWindow(
          _buildInfoWindow(
            _customInfoWindowHeight,
            _customInfoWindowWidth,
            seller,
            context,
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
      child: _buildSellerCardComponents(
        seller,
        context,
        seller.isOpen(),
      ),
    );
  }

  Widget _buildInfoWindow(double _customInfoWindowHeight,
      double _customInfoWindowWidth, Seller seller, BuildContext context) {
    return GestureDetector(
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
          height: _customInfoWindowHeight,
          width: _customInfoWindowWidth,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
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
    );
  }

  Widget _buildSellerCardComponents(
      Seller seller, BuildContext context, bool isOpen) {
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
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.8.wp),
        child: Row(
          children: [
            Container(
              width: 135,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(24.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(cor, BlendMode.saturation),
                  child: seller.logo == null
                      ? _buildSellerLogoPlaceholder()
                      : _buildSellerLogo(seller),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 0,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 0.5.wp),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: AutoSizeText(
                          name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: corTexto,
                            fontSize: 32.nsp,
                          ),
                        ),
                      ),
                    ),
                    Flexible(flex: 0, child: _isOpen(seller)),
                    Flexible(
                        flex: 0,
                        child: _botaoVerVendedor(seller, context, isOpen))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerLogo(Seller seller) {
    return CachedNetworkImage(
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
              size: 100,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerLogoPlaceholder() {
    return Stack(
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
    );
  }

  Future<void> _goToLocation(double lat, double long, {double zoom}) async {
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
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
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
      constraints: BoxConstraints(maxWidth: 0.35.wp),
      child: AutoSizeText(
        "Fechado, abre $weekdayFound às $horaFormatada",
        textAlign: TextAlign.center,
        maxLines: 2,
        style: GoogleFonts.montserrat(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _botaoVerVendedor(Seller seller, BuildContext context, var isOpen) {
    return Container(
      width: 0.25.wp,
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
            color: isOpen ? null : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext contextGeral) {
    return Positioned(
      top: 40,
      left: 1,
      width: 50,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(contextGeral).pop(),
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
                  Icons.arrow_back,
                  color: Theme.of(context).accentColor,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons(BuildContext contextGeral) {
    return Positioned(
      bottom: 156,
      right: 1,
      width: 50,
      child: Column(
        children: [
          GestureDetector(
            onTap: _loadingMyLocation
                ? () {}
                : () async {
                    setState(() => _loadingMyLocation = true);
                    _customInfoWindowController.hideInfoWindow();
                    await _updateUserLocation();
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
              child: _loadingMyLocation
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CircularProgressIndicator(
                              color: Theme.of(context).accentColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).accentColor,
                        size: 30,
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
                  size: 30,
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
      if (value['vendedor'] != null) {
        setState(() {
          _filter = value['vendedor'];
          _isCardsLoading = true;
        });
        _loadData();
      }
    } else {
      setState(() {
        _filter = '';
        _isCardsLoading = true;
      });
      _loadData();
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
      _goToLocation(seller.location.geopoint.latitude,
          seller.location.geopoint.longitude);
    }
  }

  _carregarMarcadores(List<Seller> sellers) {
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
            await _goToLocation(
              seller.location.geopoint.latitude,
              seller.location.geopoint.longitude,
              zoom: 16,
            );
            _customInfoWindowController.addInfoWindow(
              _buildInfoWindow(
                _customInfoWindowHeight,
                _customInfoWindowWidth,
                seller,
                context,
              ),
              LatLng(
                seller.location.geopoint.latitude,
                seller.location.geopoint.longitude,
              ),
            );
          },
          markerId: MarkerId(seller.id),
          position: LatLng(seller.location.geopoint.latitude,
              seller.location.geopoint.longitude),
          icon: customMarkerIcon,
          consumeTapEvents: true,
        );
        marcadoresLocal.add(marcador);
      },
    );
    return marcadoresLocal;
  }
}
