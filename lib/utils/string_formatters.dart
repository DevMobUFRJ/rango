import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rango/models/seller.dart';

String intToCurrency(int number) {
  final formatter = new NumberFormat("#,##0.00", "pt_BR");
  return "R\$ " + formatter.format(number / 100);
}

String distanceInKM(Seller seller, Position userLocation) {
  var distance = Geolocator.distanceBetween(
      seller.location.geopoint.latitude,
      seller.location.geopoint.longitude,
      userLocation.latitude,
      userLocation.longitude
  )/1000;

  return distance.toStringAsFixed(1).replaceAll('.', ',') + ' km';
}