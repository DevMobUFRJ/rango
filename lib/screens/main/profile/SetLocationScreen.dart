import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';

class SetLocationScreen extends StatefulWidget {
  final Seller user;
  SetLocationScreen(this.user);
  @override
  _SetLocationScreen createState() => _SetLocationScreen();
}

class _SetLocationScreen extends State<SetLocationScreen> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition;
  BitmapDescriptor marMarkerCustom;
  GeoPoint positionGlobal;
  Position _userLocation;
  final _geoFlutterFire = Geoflutterfire();
  Marker marker = Marker(markerId: MarkerId('seller'), consumeTapEvents: true);
  bool _loading = true;
  String _mapStyle = "[{\"featureType\": \"poi\",\"stylers\": [{ \"visibility\": \"off\" }]}]";

  @override
  initState() {
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
    _movimentarCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: AutoSizeText(
        'Localização da loja',
        style: GoogleFonts.montserrat(
          color: Theme.of(context).accentColor,
          fontSize: 35.nsp,
        ),
      )),
      body: _loading
          ? _buildLoadingSpinner()
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    markers: Set<Marker>.from([marker]),
                    initialCameraPosition: _cameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                        controller.showMarkerInfoWindow(MarkerId("seller"));
                        openMessage(
                          'Clique no mapa ou segure e arraste o marcador para selecionar a posição correta',
                          seconds: 4,
                        );
                      }
                      controller.setMapStyle(_mapStyle);

                    },
                    onTap: (newPosition) {
                      setState(() {
                        positionGlobal = GeoPoint(
                          newPosition.latitude,
                          newPosition.longitude,
                        );
                        marker = marker.copyWith(positionParam: newPosition);
                      });
                    },
                    onLongPress: (newPosition) {
                      setState(() {
                        positionGlobal = GeoPoint(
                          newPosition.latitude,
                          newPosition.longitude,
                        );
                        marker = marker.copyWith(positionParam: newPosition);
                      });
                    },
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => _gotoLocation(
                        _userLocation.latitude,
                        _userLocation.longitude,
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
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.my_location,
                            color: Theme.of(context).accentColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 0.65.wp,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        child: AutoSizeText(
                          "Definir Localização",
                          style: TextStyle(fontSize: 36.nsp),
                        ),
                        onPressed: () => _submit(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _gotoLocation(double lat, double long, {double zoom}) async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: zoom != null ? zoom : 15,
          //    tilt: 50.0,
          // bearing: 45.0,
        ),
      ),
    );
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  void _setCustomMarkers() async {
    marMarkerCustom = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/imgs/pinMapa.png');
  }

  void openMessage(String text, {int seconds}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds != null ? seconds : 2),
        backgroundColor: Theme.of(context).accentColor,
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
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

  Future<void> _recuperarLocalizacaoAtual() async {
    Position position;
    var sellerRef =
        await Repository.instance.sellersRef.doc(widget.user.id).get();
    Seller seller = sellerRef.data();
    if (seller.location != null) {
      position = Position(
        latitude: seller.location.geopoint.latitude,
        longitude: seller.location.geopoint.longitude,
      );
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    }

    Position userPosition = await Repository.instance.getUserLocation();

    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
      positionGlobal = GeoPoint(position.latitude, position.longitude);
      _userLocation = userPosition;
    });

    Marker marcador = Marker(
      draggable: true,
      onDragEnd: ((newPosition) {
        setState(() {
          positionGlobal =
              GeoPoint(newPosition.latitude, newPosition.longitude);
        });
      }),
      markerId: MarkerId("seller"),
      position: LatLng(
        seller.location.geopoint.latitude,
        seller.location.geopoint.longitude,
      ),
      consumeTapEvents: true,
      icon: marMarkerCustom,
      infoWindow: InfoWindow(title: 'Sua loja está aqui')
    );
    setState(() {
      marker = marcador;
      _loading = false;
    });
  }

  _submit() async {
    if (positionGlobal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Theme.of(context).errorColor,
          content: Text(
            'Você precisa primeiro escolher uma nova localização!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      try {
        Map<String, dynamic> dataToUpdate = {};
        GeoFirePoint location = _geoFlutterFire.point(
          latitude: positionGlobal.latitude,
          longitude: positionGlobal.longitude,
        );
        dataToUpdate['location'] = location.data;
        await Repository.instance.updateSeller(widget.user.id, dataToUpdate);
        openMessage("Atualizado com sucesso");
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Theme.of(context).errorColor,
            content: Text(
              'Ocorreu um erro ao definir a localização',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }
}
