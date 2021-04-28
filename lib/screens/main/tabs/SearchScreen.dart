import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rango/models/client.dart';
import 'package:geolocator/geolocator.dart';

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

  _carregarMarcadores() {
    Set<Marker> marcadoresLocal = {};

    Marker marcador1 = Marker(
        onTap: () {
          print("la");
        },
        markerId: MarkerId('marcador1'),
        position: LatLng(-22.882685177272624, -43.3104221811033),
        infoWindow: InfoWindow(title: "lala"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));

    Marker marcador2 = Marker(
        markerId: MarkerId('marcador2'),
        position: LatLng(-22.881775799472884, -43.310701130833344),
        infoWindow: InfoWindow(title: "hehehe"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

    marcadoresLocal.add(marcador1);
    marcadoresLocal.add(marcador2);

    setState(() {
      _marcadores = marcadoresLocal;
    });
  }

  _addListenerLocalizacao(){
    Geolocator.getPositionStream( )
    .listen((Position position) { 
      print("alterei a posição: "+position.toString());
    });
  }

  _movimentarCamera() async{
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_cameraPosition)
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

    print("localizaçao inicial: " + position.toString());
  }

  @override
  void initState() {
    super.initState();
    _recuperarLocalizacaoAtual();
    _carregarMarcadores();
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

  Widget _mapa(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        markers: _marcadores,
      ),
    );
  }
}
