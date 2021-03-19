import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/shift.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/user_notification_settings.dart';

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
  final String email;
  final String phone;
  final UserNotificationSettings notificationSettings;

  Seller({
    this.active,
    this.contact,
    this.currentMeals,
    this.location,
    this.logo,
    this.meals,
    @required this.name,
    this.picture,
    this.shift,
    this.email,
    this.phone,
    this.notificationSettings,
  });
}
