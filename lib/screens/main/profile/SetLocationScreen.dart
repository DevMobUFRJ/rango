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
          'Localização',
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
                    future: Repository.instance.getUserLocation(),
                    builder:
                        (context, AsyncSnapshot<Position> locationSnapshot) {
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
                            title: "Você está aqui",
                          ),
                          icon: marMarkerCustom);
                      marcador.onTap();
                      Set<Marker> marcadores = {};
                      marcadores.add(marcador);

                      return Stack(
                        children: [
                          GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _cameraPosition,
                            onMapCreated: (GoogleMapController controller) {
                              if (_controller.isCompleted) {
                                _controller.complete(controller);
                              }
                              controller
                                  .showMarkerInfoWindow(MarkerId("Seller"));
                              openMenssage(
                                  'Pressione o marcador e arraste para selecionar a posição correta');
                            },
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: true,
                            markers: marcadores,
                          ),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  width: 0.65.wp,
                                  child: ElevatedButton(
                                      child: AutoSizeText(
                                        "Atualizar Localização",
                                        style: TextStyle(fontSize: 36.nsp),
                                      ),
                                      onPressed: () => _submit()))),
                        ],
                      );
                    },
                  )),
            ],
          ),
        ));
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

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    positionGlobal = new GeoPoint(position.latitude, position.longitude);
    setState(() {
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 16);
    });
    _movimentarCamera();

    print("localizaçao inicial: " + position.toString());
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
 
    } catch (e) {
      print(e);
      openMenssage(e.toString());
    }
    openMenssage("Atualizado com sucesso");
  }
}
