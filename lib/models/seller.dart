import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/shift.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class Seller {
  final bool active;
  final Contact contact;
  final LatLng location;
  final String logo;
  final String name;
  final String picture;
  final Shift shift;
  final List<Meal> currentMeals;
  final List<Meal> meals;

  Seller({
    @required this.active,
    this.contact,
    @required this.currentMeals,
    @required this.location,
    this.logo,
    @required this.meals,
    @required this.name,
    this.picture,
    @required this.shift,
  });
}
