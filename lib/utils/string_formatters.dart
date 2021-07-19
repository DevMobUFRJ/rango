import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rango/models/seller.dart';

String intToCurrency(int number) {
  final formatter = new NumberFormat("#,##0.00", "pt_BR");
  return "R\$ " + formatter.format(number / 100);
}

String formatTime(int time) {
  if (time == null) return null;
  var formatted = time.toString().padLeft(4, '0');
  return formatted.substring(0, 2) + ':' + formatted.substring(2, 4);
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