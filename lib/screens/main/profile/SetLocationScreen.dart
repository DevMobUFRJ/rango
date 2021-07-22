import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Position userLocation;

  @override
  void initState() {
    super.initState();
    _setCustomMarkers();
    _recuperarLocalizacaoAtual();
  }

  var lat = 0.0;
  var long = 0.0;

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
      body: Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder(
                future: _recuperarLocalizacaoAtual(),
                builder: (context, AsyncSnapshot<Position> locationSnapshot) {
                  print(locationSnapshot);
                  if (!locationSnapshot.hasData) {
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
                  return FutureBuilder(
                      future: Repository.instance.getUserLocation(),
                      builder: (
                        ctx,
                        AsyncSnapshot<Position> userLocationSnapshot,
                      ) {
                        if (!userLocationSnapshot.hasData ||
                            userLocationSnapshot.connectionState ==
                                ConnectionState.waiting) {
                          return _buildLoadingSpinner();
                        }
                        if (userLocationSnapshot.hasError) {
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

                        userLocation = userLocationSnapshot.data;
                        Marker marcador = Marker(
                          onTap: () {
                            print("la");
                          },
                          draggable: true,
                          onDragEnd: ((newPosition) {
                            print(newPosition.latitude);
                            print(newPosition.longitude);
                            positionGlobal = new GeoPoint(
                                newPosition.latitude, newPosition.longitude);
                          }),
                          markerId: MarkerId("Seller"),
                          position: LatLng(locationSnapshot.data.latitude,
                              locationSnapshot.data.longitude),
                          infoWindow: InfoWindow(
                            title: "Sua loja está aqui",
                          ),
                          icon: marMarkerCustom,
                        );
                        marcador.onTap();
                        Set<Marker> marcadores = {};
                        marcadores.add(marcador);

                        return Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _cameraPosition == null
                                  ? CameraPosition(
                                      target: LatLng(
                                        locationSnapshot.data.latitude,
                                        locationSnapshot.data.longitude,
                                      ),
                                      zoom: 16,
                                    )
                                  : _cameraPosition,
                              onMapCreated: (GoogleMapController controller) {
                                if (!_controller.isCompleted) {
                                  _controller.complete(controller);
                                  controller
                                      .showMarkerInfoWindow(MarkerId("Seller"));
                                  openMenssage(
                                      'Segure o marcador e arraste para selecionar a posição correta');
                                }
                              },
                              zoomControlsEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              markers: marcadores,
                            ),
                            // Positioned(
                            //   right: 5,
                            //   top: 5,
                            //   child: GestureDetector(
                            //     onTap: () => _gotoLocation(
                            //       userLocation.latitude,
                            //       userLocation.longitude,
                            //       zoom: 16,
                            //     ),
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(50),
                            //         color: Colors.white,
                            //         boxShadow: [
                            //           BoxShadow(
                            //             color: Colors.grey,
                            //             offset: Offset(0.0, 1.0), //(x,y)
                            //             blurRadius: 6.0,
                            //           ),
                            //         ],
                            //       ),
                            //       child: Padding(
                            //         padding: const EdgeInsets.all(5),
                            //         child: Icon(
                            //           Icons.my_location,
                            //           color: Theme.of(context).accentColor,
                            //           size: 35,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
                        );
                      });
                },
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

  void openMenssage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
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

  Future<Position> _recuperarLocalizacaoAtual() async {
    var sellerRef =
        await Repository.instance.sellersRef.doc(widget.user.id).get();
    Seller seller = sellerRef.data();
    if (seller.location != null) {
      Position position = Position(
        latitude: seller.location.geopoint.latitude,
        longitude: seller.location.geopoint.longitude,
      );
      print(position);
      return position;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    positionGlobal = new GeoPoint(position.latitude, position.longitude);
    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
    });
    _movimentarCamera();

    print("localizaçao inicial: " + position.toString());
    return position;
  }

  // _getLocation() async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   //Position position = await Geolocator().getCurrentPosition();
  //   Position position = await Repository.instance.getUserLocation();
  //   debugPrint('location: ${position.latitude}');
  //   final coordinates = new Coordinates(position.latitude, position.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   print("${first.featureName} : ${first.addressLine}");
  //   print(
  //       ' ${first.locality} = ${first.adminArea} = ${first.subLocality} = ${first.subAdminArea} = ${first.addressLine} = ${first.featureName} = ${first.thoroughfare} =  ${first.subThoroughfare}');
  // }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  _submit() async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      Map<String, dynamic> localizacao = {};
      GeoPoint geo =
          new GeoPoint(positionGlobal.latitude, positionGlobal.longitude);
      localizacao['geohash'] = geo.hashCode.toString();
      localizacao['geopoint'] = geo;
      dataToUpdate['location'] = localizacao;
      await Repository.instance.updateSeller(widget.user.id, dataToUpdate);
      _recuperarLocalizacaoAtual();
    } catch (e) {
      print(e);
      openMenssage(e.toString());
    }
    openMenssage("Atualizado com sucesso");
  }
}
